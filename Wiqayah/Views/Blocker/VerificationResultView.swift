import SwiftUI

/// Shows verification result (success, partial, or failure)
struct VerificationResultView: View {
    let result: VerificationResult
    var onContinue: () -> Void

    @State private var animateIcon = false
    @State private var animateText = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Result icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0)

                Image(systemName: iconName)
                    .font(.system(size: 64, weight: .medium))
                    .foregroundColor(iconColor)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0)
            }

            // Result message
            VStack(spacing: 16) {
                Text(titleText)
                    .font(WiqayahFonts.header(28))
                    .foregroundColor(.white)
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)

                if result.isSuccess {
                    // Arabic blessing
                    VStack(spacing: 8) {
                        Text(MotivationalMessages.barakallah)
                            .font(.system(size: 24))
                            .foregroundColor(.white)

                        Text(MotivationalMessages.barakallahTransliteration)
                            .font(WiqayahFonts.body())
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)
                }

                Text(subtitleText)
                    .font(WiqayahFonts.body())
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(animateText ? 1.0 : 0)
                    .offset(y: animateText ? 0 : 20)
            }

            Spacer()

            // Continue button
            Button(action: onContinue) {
                Text(buttonText)
                    .font(WiqayahFonts.button())
                    .foregroundColor(buttonTextColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white)
                    .cornerRadius(28)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
            .opacity(animateText ? 1.0 : 0)
        }
        .onAppear {
            triggerHaptic()

            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                animateText = true
            }
        }
    }

    // MARK: - Computed Properties

    private var iconName: String {
        switch result {
        case .success:
            return "checkmark.circle.fill"
        case .partial:
            return "arrow.triangle.2.circlepath"
        case .failure:
            return "xmark.circle.fill"
        }
    }

    private var iconColor: Color {
        switch result {
        case .success:
            return WiqayahColors.success
        case .partial:
            return WiqayahColors.warning
        case .failure:
            return WiqayahColors.error
        }
    }

    private var iconBackgroundColor: Color {
        switch result {
        case .success:
            return WiqayahColors.success
        case .partial:
            return WiqayahColors.warning
        case .failure:
            return WiqayahColors.error
        }
    }

    private var titleText: String {
        switch result {
        case .success:
            return "Verified!"
        case .partial(let detected, let required):
            return "\(detected)/\(required) Detected"
        case .failure:
            return "Not Recognized"
        }
    }

    private var subtitleText: String {
        switch result {
        case .success:
            return "Your dhikr has been verified. May it be accepted."
        case .partial(let detected, let required):
            return "Please repeat \(required - detected) more time\(required - detected > 1 ? "s" : "")."
        case .failure(let reason):
            return reason.rawValue + ". Please try again."
        }
    }

    private var buttonText: String {
        switch result {
        case .success:
            return "Continue"
        case .partial:
            return "Continue Recording"
        case .failure:
            return "Try Again"
        }
    }

    private var buttonTextColor: Color {
        switch result {
        case .success:
            return WiqayahColors.success
        case .partial:
            return WiqayahColors.warning
        case .failure:
            return WiqayahColors.error
        }
    }

    private func triggerHaptic() {
        switch result {
        case .success:
            HapticManager.shared.success()
        case .partial:
            HapticManager.shared.warning()
        case .failure:
            HapticManager.shared.error()
        }
    }
}

// MARK: - Preview
#Preview("Success") {
    ZStack {
        WiqayahColors.primary
            .ignoresSafeArea()

        VerificationResultView(result: .success, onContinue: {})
    }
}

#Preview("Partial") {
    ZStack {
        WiqayahColors.primary
            .ignoresSafeArea()

        VerificationResultView(result: .partial(detected: 2, required: 3), onContinue: {})
    }
}

#Preview("Failure") {
    ZStack {
        WiqayahColors.primary
            .ignoresSafeArea()

        VerificationResultView(result: .failure(reason: .lowConfidence), onContinue: {})
    }
}
