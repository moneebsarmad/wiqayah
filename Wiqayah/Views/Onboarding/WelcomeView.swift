import SwiftUI

/// Welcome screen - first step of onboarding
struct WelcomeView: View {
    var onContinue: () -> Void

    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateIcon = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // App icon/logo
            ZStack {
                Circle()
                    .fill(WiqayahColors.primary.opacity(0.1))
                    .frame(width: 160, height: 160)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0)

                Image(systemName: "shield.checkered")
                    .font(.system(size: 64, weight: .medium))
                    .foregroundStyle(WiqayahColors.primaryGradient)
                    .scaleEffect(animateIcon ? 1.0 : 0.5)
                    .opacity(animateIcon ? 1.0 : 0)
            }
            .padding(.bottom, 40)

            // Title
            VStack(spacing: 16) {
                Text("Wiqayah")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(WiqayahColors.text)
                    .opacity(animateTitle ? 1.0 : 0)
                    .offset(y: animateTitle ? 0 : 20)

                Text("وقاية")
                    .font(.custom("NotoNaskhArabic-Bold", size: 32))
                    .foregroundColor(WiqayahColors.primary)
                    .opacity(animateTitle ? 1.0 : 0)
                    .offset(y: animateTitle ? 0 : 20)
            }
            .padding(.bottom, 24)

            // Subtitle
            Text("Guard your time.\nNourish your soul.")
                .font(WiqayahFonts.body(18))
                .foregroundColor(WiqayahColors.textSecondary)
                .multilineTextAlignment(.center)
                .opacity(animateSubtitle ? 1.0 : 0)
                .offset(y: animateSubtitle ? 0 : 20)

            Spacer()

            // Description
            VStack(spacing: 12) {
                featureRow(icon: "hourglass", text: "Reduce mindless scrolling")
                featureRow(icon: "heart.fill", text: "Build dhikr habits")
                featureRow(icon: "shield.fill", text: "Protect your attention")
            }
            .padding(.horizontal, 32)
            .opacity(animateSubtitle ? 1.0 : 0)

            Spacer()

            // Continue button
            Button(action: onContinue) {
                Text("Get Started")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(animateSubtitle ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateIcon = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateTitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                animateSubtitle = true
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(WiqayahColors.primary)
                .frame(width: 32)

            Text(text)
                .font(WiqayahFonts.body())
                .foregroundColor(WiqayahColors.text)

            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(onContinue: {})
        .background(WiqayahColors.background)
}
