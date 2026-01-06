import SwiftUI

/// Settings and preferences view
struct SettingsView: View {
    @StateObject private var dataManager = CoreDataManager.shared
    @StateObject private var blockerService = AppBlockerService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    @StateObject private var authManager = AuthManager.shared

    @Environment(\.dismiss) private var dismiss

    @State private var dailyLimit: Double
    @State private var showingAppSelection = false
    @State private var showingPremiumSheet = false
    @State private var showingSignOutAlert = false
    @State private var showingResetAlert = false

    init() {
        _dailyLimit = State(initialValue: Double(CoreDataManager.shared.currentUser.dailyLimitMinutes))
    }

    var body: some View {
        NavigationStack {
            List {
                // Premium section
                if !dataManager.currentUser.isPremium {
                    premiumSection
                }

                // Blocking section
                blockingSection

                // Limits section
                limitsSection

                // Prayer times section
                prayerTimesSection

                // Notifications section
                notificationsSection

                // Account section
                accountSection

                // About section
                aboutSection

                // Debug section (simulator mode)
                if blockerService.isSimulatorMode {
                    debugSection
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingAppSelection) {
                AppSelectionSheet()
            }
            .sheet(isPresented: $showingPremiumSheet) {
                PremiumUpgradeSheet()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authManager.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Reset All Data", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    dataManager.clearAllData()
                }
            } message: {
                Text("This will delete all your data including usage history and settings. This action cannot be undone.")
            }
            .onChange(of: dailyLimit) { _, newValue in
                dataManager.setDailyLimit(Int(newValue))
            }
        }
    }

    // MARK: - Premium Section
    private var premiumSection: some View {
        Section {
            Button(action: { showingPremiumSheet = true }) {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundColor(Color(hex: "#FFD700"))
                        .font(.system(size: 24))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Upgrade to Premium")
                            .font(WiqayahFonts.body())
                            .foregroundColor(WiqayahColors.text)

                        Text("Unlimited unlocks, priority support")
                            .font(WiqayahFonts.caption())
                            .foregroundColor(WiqayahColors.textSecondary)
                    }

                    Spacer()

                    Text(subscriptionService.getPriceString())
                        .font(WiqayahFonts.body(14))
                        .foregroundColor(WiqayahColors.primary)
                }
            }
        }
    }

    // MARK: - Blocking Section
    private var blockingSection: some View {
        Section("App Blocking") {
            // Blocked apps
            Button(action: { showingAppSelection = true }) {
                HStack {
                    Label("Manage Blocked Apps", systemImage: "app.badge.checkmark")

                    Spacer()

                    Text("\(dataManager.getBlockedApps().count) apps")
                        .foregroundColor(WiqayahColors.textSecondary)

                    Image(systemName: "chevron.right")
                        .foregroundColor(WiqayahColors.textSecondary)
                        .font(.system(size: 12))
                }
            }
            .foregroundColor(WiqayahColors.text)

            // Simulator mode toggle
            Toggle(isOn: $blockerService.isSimulatorMode) {
                Label("Simulator Mode", systemImage: "hammer")
            }
            .tint(WiqayahColors.primary)
        }
    }

    // MARK: - Limits Section
    private var limitsSection: some View {
        Section("Daily Limit") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Time Limit")

                    Spacer()

                    Text("\(Int(dailyLimit)) minutes")
                        .foregroundColor(WiqayahColors.primary)
                        .fontWeight(.semibold)
                }

                Slider(
                    value: $dailyLimit,
                    in: Double(User.minDailyLimit)...Double(User.maxDailyLimit),
                    step: 5
                )
                .tint(WiqayahColors.primary)

                HStack {
                    Text("\(User.minDailyLimit) min")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)

                    Spacer()

                    Text("\(User.maxDailyLimit) min")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Prayer Times Section
    private var prayerTimesSection: some View {
        Section("Prayer Times") {
            HStack {
                Label("Calculation Method", systemImage: "moon.stars")

                Spacer()

                Text(PrayerTimeService.shared.calculationMethod.rawValue)
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            HStack {
                Label("Fajr Time", systemImage: "sunrise")

                Spacer()

                Text(PrayerTimeService.shared.getFormattedFajrTime())
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            HStack {
                Label("Resets In", systemImage: "clock")

                Spacer()

                Text(PrayerTimeService.shared.getTimeUntilReset())
                    .foregroundColor(WiqayahColors.textSecondary)
            }
        }
    }

    // MARK: - Notifications Section
    private var notificationsSection: some View {
        Section("Notifications") {
            NavigationLink(destination: NotificationSettingsView()) {
                Label("Notification Settings", systemImage: "bell")
            }
        }
    }

    // MARK: - Account Section
    private var accountSection: some View {
        Section("Account") {
            if authManager.isAuthenticated {
                HStack {
                    Label("Signed In", systemImage: "person.circle.fill")

                    Spacer()

                    Text(authManager.userName ?? "Apple ID")
                        .foregroundColor(WiqayahColors.textSecondary)
                }

                Button(role: .destructive, action: { showingSignOutAlert = true }) {
                    Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } else {
                SignInWithAppleButton()
                    .frame(height: 44)
            }

            if dataManager.currentUser.isPremium {
                Button(action: {
                    Task { await subscriptionService.restorePurchases() }
                }) {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                }
            }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")

                Spacer()

                Text("\(AppInfo.appVersion) (\(AppInfo.buildNumber))")
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            Link(destination: AppInfo.privacyPolicyURL) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: AppInfo.termsOfServiceURL) {
                Label("Terms of Service", systemImage: "doc.text")
            }

            Button(action: {
                if let url = URL(string: "mailto:\(AppInfo.supportEmail)") {
                    UIApplication.shared.open(url)
                }
            }) {
                Label("Contact Support", systemImage: "envelope")
            }
        }
    }

    // MARK: - Debug Section
    private var debugSection: some View {
        Section("Debug") {
            Button(action: {
                blockerService.resetSimulatedUsage()
            }) {
                Label("Reset Simulated Usage", systemImage: "arrow.counterclockwise")
            }

            Button(action: {
                dataManager.checkAndResetDaily()
            }) {
                Label("Force Daily Reset", systemImage: "clock.arrow.circlepath")
            }

            Button(role: .destructive, action: { showingResetAlert = true }) {
                Label("Reset All Data", systemImage: "trash")
            }
        }
    }
}

// MARK: - App Selection Sheet
struct AppSelectionSheet: View {
    @StateObject private var dataManager = CoreDataManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(dataManager.blockedApps) { app in
                    HStack {
                        AppIconView(app: app, size: 44)

                        Text(app.name)
                            .font(WiqayahFonts.body())

                        Spacer()

                        Toggle("", isOn: Binding(
                            get: { app.isBlocked },
                            set: { _ in dataManager.toggleAppBlock(bundleId: app.id) }
                        ))
                        .tint(WiqayahColors.primary)
                    }
                }
            }
            .navigationTitle("Blocked Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Premium Upgrade Sheet
struct PremiumUpgradeSheet: View {
    @StateObject private var subscriptionService = SubscriptionService.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Premium icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 64))
                    .foregroundColor(Color(hex: "#FFD700"))

                Text("Wiqayah Premium")
                    .font(WiqayahFonts.header())

                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    benefitRow(icon: "infinity", text: "Unlimited daily unlocks")
                    benefitRow(icon: "bolt.fill", text: "Priority support")
                    benefitRow(icon: "chart.bar.fill", text: "Advanced statistics")
                    benefitRow(icon: "heart.fill", text: "Support development")
                }
                .padding(.horizontal, 32)

                Spacer()

                // Price
                Text(subscriptionService.getPriceString())
                    .font(WiqayahFonts.header(24))
                    .foregroundColor(WiqayahColors.text)

                // Purchase button
                Button(action: {
                    Task {
                        if await subscriptionService.purchasePremium() {
                            dismiss()
                        }
                    }
                }) {
                    if subscriptionService.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Subscribe Now")
                    }
                }
                .primaryButtonStyle()
                .padding(.horizontal, 24)

                // Restore purchases
                Button(action: {
                    Task { await subscriptionService.restorePurchases() }
                }) {
                    Text("Restore Purchases")
                        .font(WiqayahFonts.body())
                        .foregroundColor(WiqayahColors.primary)
                }
                .padding(.bottom, 40)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(hex: "#FFD700"))
                .frame(width: 32)

            Text(text)
                .font(WiqayahFonts.body())
                .foregroundColor(WiqayahColors.text)
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @StateObject private var notificationService = NotificationService.shared

    @State private var usageWarnings = true
    @State private var fajrReminder = true
    @State private var streakReminder = true

    var body: some View {
        List {
            Section {
                Toggle("Usage Warnings", isOn: $usageWarnings)
                Toggle("Fajr Reminder", isOn: $fajrReminder)
                Toggle("Streak Reminder", isOn: $streakReminder)
            } footer: {
                Text("Manage which notifications Wiqayah can send you.")
            }

            Section {
                if !notificationService.isAuthorized {
                    Button(action: {
                        Task { await notificationService.requestAuthorization() }
                    }) {
                        Label("Enable Notifications", systemImage: "bell.badge")
                    }
                } else {
                    HStack {
                        Label("Notifications Enabled", systemImage: "checkmark.circle.fill")
                            .foregroundColor(WiqayahColors.success)

                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .tint(WiqayahColors.primary)
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
}
