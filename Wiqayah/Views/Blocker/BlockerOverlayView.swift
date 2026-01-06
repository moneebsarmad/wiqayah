import SwiftUI

/// THE CRITICAL SCREEN - Shows when user tries to open a blocked app
struct BlockerOverlayView: View {
    let blockedApp: BlockedApp
    var onDismiss: () -> Void

    @StateObject private var dataManager = CoreDataManager.shared
    @StateObject private var blockerService = AppBlockerService.shared
    @StateObject private var verificationService = DhikrVerificationService.shared
    @StateObject private var usageService = UsageTrackingService.shared

    @State private var currentState: BlockerState = .initial
    @State private var dhikrRequirement: DhikrRequirement?

    enum BlockerState {
        case initial
        case recording
        case verifying
        case success
        case partial(detected: Int, required: Int)
        case failure
        case limitReached
        case emergencyBypass
    }

    var body: some View {
        ZStack {
            // Background
            WiqayahColors.primary
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                }

                Spacer()

                // Content based on state
                Group {
                    switch currentState {
                    case .initial:
                        initialView
                    case .recording:
                        RecordingView(
                            requirement: dhikrRequirement ?? .subhanallah,
                            onComplete: handleRecordingComplete,
                            onCancel: { currentState = .initial }
                        )
                    case .verifying:
                        verifyingView
                    case .success:
                        VerificationResultView(
                            result: .success,
                            onContinue: handleUnlock
                        )
                    case .partial(let detected, let required):
                        VerificationResultView(
                            result: .partial(detected: detected, required: required),
                            onContinue: { currentState = .recording }
                        )
                    case .failure:
                        VerificationResultView(
                            result: .failure(reason: .lowConfidence),
                            onContinue: { currentState = .initial }
                        )
                    case .limitReached:
                        LimitReachedView(onDismiss: onDismiss)
                    case .emergencyBypass:
                        emergencyBypassView
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            checkInitialState()
        }
    }

    // MARK: - Initial View
    private var initialView: some View {
        VStack(spacing: 32) {
            // App being blocked
            VStack(spacing: 16) {
                AppIconView(app: blockedApp, size: 80, showBlockedOverlay: true)

                Text("Opening \(blockedApp.name)")
                    .font(WiqayahFonts.header(24))
                    .foregroundColor(.white)
            }

            // Usage info
            VStack(spacing: 8) {
                Text("Time used today")
                    .font(WiqayahFonts.body())
                    .foregroundColor(.white.opacity(0.7))

                Text("\(usageService.todayTotalMinutes) / \(dataManager.currentUser.dailyLimitMinutes) min")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: geometry.size.width * CGFloat(usageService.usagePercentage), height: 8)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)
            }

            // Dhikr requirement
            if let requirement = dhikrRequirement {
                VStack(spacing: 12) {
                    Text("To unlock, recite:")
                        .font(WiqayahFonts.body())
                        .foregroundColor(.white.opacity(0.7))

                    Text(requirement.arabic)
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                    Text(requirement.displayText)
                        .font(WiqayahFonts.body())
                        .foregroundColor(.white.opacity(0.8))

                    if dataManager.currentUser.hasDebt {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text("\(dataManager.currentUser.debtMultiplier)× multiplier active")
                        }
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.warning)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(WiqayahColors.warning.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }

            // Record button
            Button(action: startRecording) {
                HStack(spacing: 12) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))

                    Text("Tap to Recite")
                        .font(WiqayahFonts.button())
                }
                .foregroundColor(WiqayahColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.white)
                .cornerRadius(30)
            }
            .padding(.horizontal, 40)

            // Emergency bypass link
            if verificationService.canUseEmergencyBypass() {
                Button(action: { currentState = .emergencyBypass }) {
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                        Text("Emergency Bypass (\(verificationService.getRemainingBypasses()) left)")
                    }
                    .font(WiqayahFonts.caption())
                    .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 8)
            }

            // Unlocks remaining
            if !dataManager.currentUser.isPremium {
                Text("\(verificationService.getRemainingUnlocks()) unlocks remaining today")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    // MARK: - Verifying View
    private var verifyingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Verifying...")
                .font(WiqayahFonts.body())
                .foregroundColor(.white)
        }
    }

    // MARK: - Emergency Bypass View
    private var emergencyBypassView: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.shield.fill")
                .font(.system(size: 48))
                .foregroundColor(WiqayahColors.warning)

            Text("Emergency Bypass")
                .font(WiqayahFonts.header(24))
                .foregroundColor(.white)

            Text("Using a bypass will add debt. Your next unlock will require \(dataManager.currentUser.debtMultiplier + 1)× the normal dhikr.")
                .font(WiqayahFonts.body())
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 12) {
                Button(action: useEmergencyBypass) {
                    Text("Use Bypass")
                        .font(WiqayahFonts.button())
                        .foregroundColor(WiqayahColors.warning)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .cornerRadius(28)
                }

                Button(action: { currentState = .initial }) {
                    Text("Go Back")
                        .font(WiqayahFonts.body())
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 40)
        }
    }

    // MARK: - Actions

    private func checkInitialState() {
        // Check if limit reached
        if usageService.hasReachedLimit {
            currentState = .limitReached
            return
        }

        // Check if can unlock
        if !verificationService.canUnlock() {
            currentState = .limitReached
            return
        }

        // Get required dhikr
        dhikrRequirement = verificationService.getRequiredDhikr()
    }

    private func startRecording() {
        HapticManager.shared.mediumImpact()
        currentState = .recording
    }

    private func handleRecordingComplete(spokenText: String) {
        currentState = .verifying

        guard let requirement = dhikrRequirement else {
            currentState = .failure
            return
        }

        // Verify the dhikr
        let result = verificationService.verifyDhikr(spokenText: spokenText, requirement: requirement)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch result {
            case .success:
                currentState = .success
            case .partial(let detected, let required):
                currentState = .partial(detected: detected, required: required)
            case .failure:
                currentState = .failure
            }
        }
    }

    private func handleUnlock() {
        // Simulate unlock
        blockerService.simulateUnlock(bundleId: blockedApp.id)

        // Show post-recitation view briefly, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    private func useEmergencyBypass() {
        verificationService.useEmergencyBypass()
        blockerService.simulateUnlock(bundleId: blockedApp.id)
        onDismiss()
    }
}

// MARK: - Preview
#Preview {
    BlockerOverlayView(
        blockedApp: BlockedApp.supportedApps[0],
        onDismiss: {}
    )
}
