import SwiftUI

/// Explains how the app works - second step of onboarding
struct HowItWorksView: View {
    var onContinue: () -> Void

    @State private var currentPage = 0

    private let steps: [(icon: String, title: String, description: String)] = [
        (
            icon: "hand.tap.fill",
            title: "Open a Blocked App",
            description: "When you try to open TikTok, Instagram, or other selected apps, Wiqayah will intercept."
        ),
        (
            icon: "mic.fill",
            title: "Recite Dhikr",
            description: "Before unlocking, recite a short dhikr. The requirement increases with your daily usage."
        ),
        (
            icon: "checkmark.circle.fill",
            title: "Verified & Unlocked",
            description: "Once your dhikr is verified, enjoy your limited screen time mindfully."
        ),
        (
            icon: "clock.fill",
            title: "Daily Reset at Fajr",
            description: "Your limits reset at Fajr prayer time. Each day is a fresh start."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("How It Works")
                .font(WiqayahFonts.header())
                .foregroundColor(WiqayahColors.text)
                .padding(.top, 40)

            Spacer()

            // Step cards
            TabView(selection: $currentPage) {
                ForEach(0..<steps.count, id: \.self) { index in
                    stepCard(step: steps[index], number: index + 1)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 400)

            Spacer()

            // Dhikr escalation preview
            dhikrEscalationView
                .padding(.horizontal, 24)

            Spacer()

            // Continue button
            Button(action: onContinue) {
                Text("I Understand")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Step Card
    private func stepCard(step: (icon: String, title: String, description: String), number: Int) -> some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(WiqayahColors.primary.opacity(0.1))
                    .frame(width: 100, height: 100)

                Image(systemName: step.icon)
                    .font(.system(size: 40))
                    .foregroundColor(WiqayahColors.primary)
            }

            VStack(spacing: 12) {
                HStack {
                    Text("Step \(number)")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(WiqayahColors.primary.opacity(0.1))
                        .clipShape(Capsule())
                }

                Text(step.title)
                    .font(WiqayahFonts.header(22))
                    .foregroundColor(WiqayahColors.text)

                Text(step.description)
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Dhikr Escalation View
    private var dhikrEscalationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Dhikr Requirements")
                .font(WiqayahFonts.body(15))
                .fontWeight(.semibold)
                .foregroundColor(WiqayahColors.text)

            VStack(spacing: 8) {
                escalationRow(time: "0-20 min", dhikr: "3× Subhanallah")
                escalationRow(time: "20-40 min", dhikr: "Ayat al-Kursi")
                escalationRow(time: "40-55 min", dhikr: "Surah al-Kahf (5 ayat)")
                escalationRow(time: "55-60 min", dhikr: "Full Adhkar Set")
            }
        }
        .padding(16)
        .background(WiqayahColors.primary.opacity(0.05))
        .cornerRadius(Constants.Sizing.cornerRadius)
    }

    private func escalationRow(time: String, dhikr: String) -> some View {
        HStack {
            Text(time)
                .font(WiqayahFonts.caption())
                .foregroundColor(WiqayahColors.textSecondary)
                .frame(width: 80, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.system(size: 10))
                .foregroundColor(WiqayahColors.textSecondary)

            Text(dhikr)
                .font(WiqayahFonts.caption())
                .foregroundColor(WiqayahColors.text)

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    HowItWorksView(onContinue: {})
        .background(WiqayahColors.background)
}
