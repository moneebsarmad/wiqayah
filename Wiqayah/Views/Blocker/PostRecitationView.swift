import SwiftUI

/// Shows motivational message after successful dhikr verification
struct PostRecitationView: View {
    var remainingMinutes: Int
    var onDismiss: () -> Void

    @State private var animateContent = false
    @State private var countdown: Int = 5
    @State private var timer: Timer?

    private var motivationalMessage: String {
        MotivationalMessages.randomPostDhikrMessage(remainingMinutes: remainingMinutes)
    }

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    WiqayahColors.primary,
                    WiqayahColors.secondary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.white)
                        .symbolEffect(.bounce, value: animateContent)
                }
                .scaleEffect(animateContent ? 1.0 : 0.8)
                .opacity(animateContent ? 1.0 : 0)

                // Blessing text
                VStack(spacing: 12) {
                    Text(MotivationalMessages.barakallah)
                        .font(.system(size: 28))
                        .foregroundColor(.white)

                    Text(MotivationalMessages.barakallahMeaning)
                        .font(WiqayahFonts.body())
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(animateContent ? 1.0 : 0)
                .offset(y: animateContent ? 0 : 20)

                // Motivational message
                Text(motivationalMessage)
                    .font(WiqayahFonts.body(18))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(animateContent ? 1.0 : 0)
                    .offset(y: animateContent ? 0 : 20)

                Spacer()

                // Auto-dismiss countdown
                VStack(spacing: 12) {
                    Text("Unlocking in \(countdown)...")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(.white.opacity(0.6))

                    // Progress indicator
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white)
                                .frame(width: geometry.size.width * CGFloat(countdown) / 5.0, height: 4)
                                .animation(.linear(duration: 1), value: countdown)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 60)

                    Button(action: onDismiss) {
                        Text("Skip")
                            .font(WiqayahFonts.body())
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animateContent = true
            }
            startCountdown()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 1 {
                countdown -= 1
                HapticManager.shared.tick()
            } else {
                timer?.invalidate()
                onDismiss()
            }
        }
    }
}

// MARK: - Compact Post Recitation (for inline display)
struct CompactPostRecitationView: View {
    var remainingMinutes: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(WiqayahColors.success)

                Text("Unlocked!")
                    .font(WiqayahFonts.body())
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)
            }

            Text(MotivationalMessages.randomPostDhikrMessage(remainingMinutes: remainingMinutes))
                .font(WiqayahFonts.caption())
                .foregroundColor(WiqayahColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .cardStyle()
    }
}

// MARK: - Preview
#Preview {
    PostRecitationView(remainingMinutes: 37, onDismiss: {})
}

#Preview("Compact") {
    CompactPostRecitationView(remainingMinutes: 37)
        .padding()
        .background(WiqayahColors.background)
}
