import SwiftUI

/// Daily limit selection - fourth step of onboarding
struct SetLimitView: View {
    @Binding var dailyLimit: Int
    var onContinue: () -> Void

    private let presetLimits = [30, 45, 60, 90, 120]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Set Your Daily Limit")
                    .font(WiqayahFonts.header())
                    .foregroundColor(WiqayahColors.text)

                Text("How much time do you want to spend on social media each day?")
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 40)
            .padding(.bottom, 40)

            // Large time display
            VStack(spacing: 8) {
                Text("\(dailyLimit)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(WiqayahColors.primary)

                Text("minutes per day")
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)
            }
            .padding(.bottom, 40)

            // Slider
            VStack(spacing: 16) {
                Slider(
                    value: Binding(
                        get: { Double(dailyLimit) },
                        set: { dailyLimit = Int($0) }
                    ),
                    in: Double(User.minDailyLimit)...Double(User.maxDailyLimit),
                    step: 5
                )
                .tint(WiqayahColors.primary)
                .padding(.horizontal, 24)

                // Range labels
                HStack {
                    Text("\(User.minDailyLimit) min")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)

                    Spacer()

                    Text("\(User.maxDailyLimit) min")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }
                .padding(.horizontal, 24)
            }
            .padding(.bottom, 32)

            // Preset buttons
            VStack(alignment: .leading, spacing: 12) {
                Text("Quick Select")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
                    .padding(.horizontal, 24)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(presetLimits, id: \.self) { limit in
                            PresetButton(
                                minutes: limit,
                                isSelected: dailyLimit == limit,
                                onTap: {
                                    HapticManager.shared.selectionChanged()
                                    withAnimation(.spring(response: 0.3)) {
                                        dailyLimit = limit
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            // Recommendation
            recommendationCard
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            // Continue button
            Button(action: onContinue) {
                Text("Continue")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    // MARK: - Recommendation Card
    private var recommendationCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 20))
                .foregroundColor(WiqayahColors.warning)

            VStack(alignment: .leading, spacing: 4) {
                Text("Recommendation")
                    .font(WiqayahFonts.body(14))
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)

                Text("Start with 60 minutes and adjust based on your needs.")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(WiqayahColors.warning.opacity(0.1))
        .cornerRadius(Constants.Sizing.cornerRadius)
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let minutes: Int
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text("\(minutes)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))

                Text("min")
                    .font(WiqayahFonts.caption())
            }
            .foregroundColor(isSelected ? .white : WiqayahColors.text)
            .frame(width: 64, height: 64)
            .background(isSelected ? WiqayahColors.primary : WiqayahColors.primary.opacity(0.1))
            .cornerRadius(Constants.Sizing.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var limit = 60

        var body: some View {
            SetLimitView(dailyLimit: $limit, onContinue: {})
                .background(WiqayahColors.background)
        }
    }

    return PreviewWrapper()
}
