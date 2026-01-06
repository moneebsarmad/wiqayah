import SwiftUI

/// Premium status badge and upgrade prompt components
struct PremiumBadge: View {
    var style: Style = .small

    enum Style {
        case small
        case medium
        case large
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "crown.fill")
                .font(.system(size: fontSize))

            if style != .small {
                Text("Premium")
                    .font(.system(size: fontSize, weight: .semibold))
            }
        }
        .foregroundColor(.white)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .background(
            LinearGradient(
                colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
    }

    private var fontSize: CGFloat {
        switch style {
        case .small: return 10
        case .medium: return 12
        case .large: return 14
        }
    }

    private var horizontalPadding: CGFloat {
        switch style {
        case .small: return 6
        case .medium: return 10
        case .large: return 14
        }
    }

    private var verticalPadding: CGFloat {
        switch style {
        case .small: return 4
        case .medium: return 6
        case .large: return 8
        }
    }
}

// MARK: - Unlock Counter Badge
struct UnlockCounterBadge: View {
    let used: Int
    let total: Int
    var isPremium: Bool = false

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.open.fill")
                .font(.system(size: 12))

            if isPremium {
                Text("Unlimited")
                    .font(WiqayahFonts.caption())
            } else {
                Text("\(used)/\(total)")
                    .font(WiqayahFonts.caption())
            }
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(badgeColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var badgeColor: Color {
        if isPremium {
            return Color(hex: "#FFD700")
        } else if used >= total {
            return WiqayahColors.error
        } else if used >= total - 3 {
            return WiqayahColors.warning
        } else {
            return WiqayahColors.primary
        }
    }
}

// MARK: - Emergency Bypass Badge
struct BypassBadge: View {
    let remaining: Int
    let total: Int = 3

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 12))

            Text("\(remaining)/\(total)")
                .font(WiqayahFonts.caption())
        }
        .foregroundColor(badgeColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(badgeColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var badgeColor: Color {
        if remaining == 0 {
            return WiqayahColors.error
        } else if remaining == 1 {
            return WiqayahColors.warning
        } else {
            return WiqayahColors.secondary
        }
    }
}

// MARK: - Premium Upgrade Card
struct PremiumUpgradeCard: View {
    var price: String = "$2.99/month"
    var onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundColor(Color(hex: "#FFD700"))

                Text("Upgrade to Premium")
                    .font(WiqayahFonts.header(20))
                    .foregroundColor(WiqayahColors.text)

                Spacer()
            }

            // Benefits
            VStack(alignment: .leading, spacing: 8) {
                benefitRow(icon: "infinity", text: "Unlimited daily unlocks")
                benefitRow(icon: "bolt.fill", text: "Priority support")
                benefitRow(icon: "chart.bar.fill", text: "Advanced statistics")
            }

            // Price and CTA
            HStack {
                Text(price)
                    .font(WiqayahFonts.body(15))
                    .foregroundColor(WiqayahColors.textSecondary)

                Spacer()

                Button(action: onUpgrade) {
                    Text("Upgrade")
                        .font(WiqayahFonts.button())
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .fill(Color.white)
                .shadow(color: Color(hex: "#FFD700").opacity(0.2), radius: 10, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "#FFD700").opacity(0.5), Color(hex: "#FFA500").opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#FFD700"))
                .frame(width: 20)

            Text(text)
                .font(WiqayahFonts.body(15))
                .foregroundColor(WiqayahColors.text)
        }
    }
}

// MARK: - Limit Reached Upgrade Prompt
struct LimitReachedPrompt: View {
    var remainingUnlocks: Int = 0
    var onUpgrade: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(WiqayahColors.error)

            Text("Daily Unlock Limit Reached")
                .font(WiqayahFonts.header(20))
                .foregroundColor(WiqayahColors.text)

            Text("Upgrade to Premium for unlimited unlocks")
                .font(WiqayahFonts.body())
                .foregroundColor(WiqayahColors.textSecondary)
                .multilineTextAlignment(.center)

            Button(action: onUpgrade) {
                HStack {
                    Image(systemName: "crown.fill")
                    Text("Upgrade Now")
                }
                .primaryButtonStyle()
            }
        }
        .padding(24)
        .cardStyle()
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 30) {
            // Badges
            HStack(spacing: 20) {
                PremiumBadge(style: .small)
                PremiumBadge(style: .medium)
                PremiumBadge(style: .large)
            }

            // Counter badges
            HStack(spacing: 20) {
                UnlockCounterBadge(used: 5, total: 15)
                UnlockCounterBadge(used: 13, total: 15)
                UnlockCounterBadge(used: 15, total: 15)
            }

            HStack(spacing: 20) {
                BypassBadge(remaining: 3)
                BypassBadge(remaining: 1)
                BypassBadge(remaining: 0)
            }

            // Premium card
            PremiumUpgradeCard { }
                .padding(.horizontal)

            // Limit reached
            LimitReachedPrompt { }
                .padding(.horizontal)
        }
        .padding(.vertical)
    }
    .background(WiqayahColors.background)
}
