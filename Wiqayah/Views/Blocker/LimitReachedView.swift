import SwiftUI

/// Shows when daily limit has been reached - hard block until reset
struct LimitReachedView: View {
    var onDismiss: () -> Void

    @StateObject private var dataManager = CoreDataManager.shared
    @StateObject private var prayerService = PrayerTimeService.shared

    @State private var animateContent = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Lock icon
            ZStack {
                Circle()
                    .fill(WiqayahColors.error.opacity(0.2))
                    .frame(width: 140, height: 140)

                Image(systemName: "lock.circle.fill")
                    .font(.system(size: 72))
                    .foregroundColor(WiqayahColors.error)
            }
            .scaleEffect(animateContent ? 1.0 : 0.8)
            .opacity(animateContent ? 1.0 : 0)

            // Title
            VStack(spacing: 16) {
                Text("Daily Limit Reached")
                    .font(WiqayahFonts.header(28))
                    .foregroundColor(.white)

                Text(MotivationalMessages.randomLimitReached())
                    .font(WiqayahFonts.body())
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .opacity(animateContent ? 1.0 : 0)
            .offset(y: animateContent ? 0 : 20)

            Spacer()

            // Stats summary
            statsCard
                .padding(.horizontal, 24)
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 20)

            // Reset time
            VStack(spacing: 8) {
                Text("Resets at Fajr")
                    .font(WiqayahFonts.body())
                    .foregroundColor(.white.opacity(0.7))

                Text(prayerService.getFormattedFajrTime())
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("in \(prayerService.getTimeUntilReset())")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(.white.opacity(0.6))
            }
            .opacity(animateContent ? 1.0 : 0)

            Spacer()

            // Action buttons
            VStack(spacing: 16) {
                NavigationLink(destination: StatsView()) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text("View Statistics")
                    }
                    .font(WiqayahFonts.button())
                    .foregroundColor(WiqayahColors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
                }

                Button(action: onDismiss) {
                    Text("Close")
                        .font(WiqayahFonts.body())
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .onAppear {
            HapticManager.shared.limitReached()

            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
        }
    }

    // MARK: - Stats Card
    private var statsCard: some View {
        VStack(spacing: 16) {
            Text("Today's Summary")
                .font(WiqayahFonts.body(14))
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 24) {
                statItem(
                    value: "\(dataManager.currentUser.dailyLimitMinutes)",
                    label: "Minutes Used"
                )

                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))

                statItem(
                    value: "\(dataManager.currentUser.unlocksUsedToday)",
                    label: "Unlocks"
                )

                Divider()
                    .frame(height: 40)
                    .background(Color.white.opacity(0.3))

                statItem(
                    value: "\(dataManager.getTodayStats().dhikrCompleted)",
                    label: "Dhikr"
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(Constants.Sizing.cornerRadius)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(WiqayahFonts.caption())
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Compact Limit Warning
struct LimitWarningBanner: View {
    var remainingMinutes: Int

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(WiqayahColors.warning)

            VStack(alignment: .leading, spacing: 2) {
                Text("Approaching Limit")
                    .font(WiqayahFonts.body(14))
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)

                Text("Only \(remainingMinutes) minutes remaining today")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(WiqayahColors.warning.opacity(0.1))
        .cornerRadius(Constants.Sizing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .stroke(WiqayahColors.warning.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ZStack {
            WiqayahColors.primary
                .ignoresSafeArea()

            LimitReachedView(onDismiss: {})
        }
    }
}

#Preview("Warning Banner") {
    LimitWarningBanner(remainingMinutes: 8)
        .padding()
        .background(WiqayahColors.background)
}
