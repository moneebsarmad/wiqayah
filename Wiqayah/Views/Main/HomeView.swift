import SwiftUI

/// Main home screen showing daily progress and quick actions
struct HomeView: View {
    @StateObject private var dataManager = CoreDataManager.shared
    @StateObject private var blockerService = AppBlockerService.shared
    @StateObject private var usageService = UsageTrackingService.shared

    @State private var showingSettings = false
    @State private var showingBlockerOverlay = false
    @State private var selectedAppForTest: BlockedApp?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Greeting header
                    greetingHeader
                        .padding(.horizontal, 20)

                    // Usage progress card
                    usageProgressCard
                        .padding(.horizontal, 20)

                    // Quick stats
                    quickStatsRow
                        .padding(.horizontal, 20)

                    // Blocked apps section
                    blockedAppsSection
                        .padding(.horizontal, 20)

                    // Simulator section (for testing)
                    if blockerService.isSimulatorMode {
                        simulatorSection
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 20)
            }
            .background(WiqayahColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(WiqayahColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .fullScreenCover(isPresented: $showingBlockerOverlay) {
                if let app = selectedAppForTest {
                    BlockerOverlayView(
                        blockedApp: app,
                        onDismiss: {
                            showingBlockerOverlay = false
                            selectedAppForTest = nil
                        }
                    )
                }
            }
        }
    }

    // MARK: - Greeting Header
    private var greetingHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(MotivationalMessages.greeting())
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)

                Text("Your Daily Progress")
                    .font(WiqayahFonts.header())
                    .foregroundColor(WiqayahColors.text)
            }

            Spacer()

            // Premium badge if applicable
            if dataManager.currentUser.isPremium {
                PremiumBadge(style: .medium)
            }
        }
    }

    // MARK: - Usage Progress Card
    private var usageProgressCard: some View {
        VStack(spacing: 20) {
            HStack {
                CircularUsageView(
                    minutesUsed: usageService.todayTotalMinutes,
                    limit: dataManager.currentUser.dailyLimitMinutes
                )

                Spacer()

                VStack(alignment: .trailing, spacing: 16) {
                    // Remaining time
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(usageService.getRemainingMinutes())")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(WiqayahColors.primary)

                        Text("minutes left")
                            .font(WiqayahFonts.caption())
                            .foregroundColor(WiqayahColors.textSecondary)
                    }

                    // Reset time
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Resets at Fajr")
                            .font(WiqayahFonts.caption())
                            .foregroundColor(WiqayahColors.textSecondary)

                        Text(PrayerTimeService.shared.getFormattedFajrTime())
                            .font(WiqayahFonts.body(14))
                            .fontWeight(.semibold)
                            .foregroundColor(WiqayahColors.text)
                    }
                }
            }

            // Status message
            if usageService.hasReachedLimit {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(WiqayahColors.error)

                    Text("Daily limit reached")
                        .font(WiqayahFonts.body())
                        .foregroundColor(WiqayahColors.error)
                }
            } else if usageService.isApproachingLimit {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(WiqayahColors.warning)

                    Text(MotivationalMessages.randomLimitWarning())
                        .font(WiqayahFonts.body(14))
                        .foregroundColor(WiqayahColors.warning)
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Quick Stats Row
    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            // Unlocks used
            StatCard(
                icon: "lock.open.fill",
                value: dataManager.currentUser.isPremium
                    ? "∞"
                    : "\(dataManager.currentUser.unlocksUsedToday)",
                label: "Unlocks",
                sublabel: dataManager.currentUser.isPremium
                    ? "Unlimited"
                    : "of \(User.freeUnlockLimit)"
            )

            // Emergency bypasses
            StatCard(
                icon: "exclamationmark.shield.fill",
                value: "\(dataManager.currentUser.emergencyBypassesRemaining)",
                label: "Bypasses",
                sublabel: "remaining"
            )

            // Dhikr debt
            if dataManager.currentUser.hasDebt {
                StatCard(
                    icon: "arrow.triangle.2.circlepath",
                    value: "\(dataManager.currentUser.debtMultiplier)×",
                    label: "Debt",
                    sublabel: "multiplier",
                    accentColor: WiqayahColors.warning
                )
            } else {
                StatCard(
                    icon: "checkmark.seal.fill",
                    value: "0",
                    label: "Debt",
                    sublabel: "clear",
                    accentColor: WiqayahColors.success
                )
            }
        }
    }

    // MARK: - Blocked Apps Section
    private var blockedAppsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Blocked Apps")
                    .font(WiqayahFonts.body())
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)

                Spacer()

                NavigationLink(destination: StatsView()) {
                    Text("View Stats")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.primary)
                }
            }

            let blockedApps = dataManager.getBlockedApps()

            if blockedApps.isEmpty {
                emptyBlockedAppsView
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(blockedApps) { app in
                            VStack(spacing: 8) {
                                AppIconView(app: app, size: 50, showBlockedOverlay: true)

                                Text(app.name)
                                    .font(WiqayahFonts.caption())
                                    .foregroundColor(WiqayahColors.text)

                                Text("\(dataManager.getUsageMinutes(for: app.id)) min")
                                    .font(WiqayahFonts.caption())
                                    .foregroundColor(WiqayahColors.textSecondary)
                            }
                        }
                    }
                }
            }
        }
        .cardStyle()
    }

    private var emptyBlockedAppsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shield.slash")
                .font(.system(size: 32))
                .foregroundColor(WiqayahColors.textSecondary)

            Text("No apps blocked yet")
                .font(WiqayahFonts.body())
                .foregroundColor(WiqayahColors.textSecondary)

            Button(action: { showingSettings = true }) {
                Text("Add Apps")
                    .font(WiqayahFonts.body(14))
                    .foregroundColor(WiqayahColors.primary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Simulator Section
    private var simulatorSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "hammer.fill")
                    .foregroundColor(WiqayahColors.warning)

                Text("Simulator Mode")
                    .font(WiqayahFonts.body())
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)

                Spacer()

                Text("Testing Only")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(WiqayahColors.warning.opacity(0.1))
                    .cornerRadius(4)
            }

            Text("Tap an app to test the blocking flow:")
                .font(WiqayahFonts.caption())
                .foregroundColor(WiqayahColors.textSecondary)

            let blockedApps = dataManager.getBlockedApps()
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70))], spacing: 16) {
                ForEach(blockedApps) { app in
                    Button(action: {
                        selectedAppForTest = app
                        showingBlockerOverlay = true
                    }) {
                        VStack(spacing: 4) {
                            AppIconView(app: app, size: 50)
                            Text("Test")
                                .font(WiqayahFonts.caption())
                                .foregroundColor(WiqayahColors.primary)
                        }
                    }
                }
            }

            // Add usage button
            Button(action: {
                blockerService.addSimulatedUsage(minutes: 10)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add 10 min usage")
                }
                .font(WiqayahFonts.body(14))
                .foregroundColor(WiqayahColors.primary)
            }
        }
        .cardStyle()
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .stroke(WiqayahColors.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let sublabel: String
    var accentColor: Color = WiqayahColors.primary

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(accentColor)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(WiqayahColors.text)

            VStack(spacing: 2) {
                Text(label)
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.text)

                Text(sublabel)
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(Constants.Sizing.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
