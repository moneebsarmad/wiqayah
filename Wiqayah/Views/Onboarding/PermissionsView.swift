import SwiftUI

/// Permissions request - final step of onboarding
struct PermissionsView: View {
    var onComplete: () -> Void

    @State private var microphoneGranted = false
    @State private var notificationsGranted = false
    @State private var isRequestingPermissions = false

    private let speechService = SpeechRecognitionService.shared
    private let notificationService = NotificationService.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Enable Permissions")
                    .font(WiqayahFonts.header())
                    .foregroundColor(WiqayahColors.text)

                Text("Wiqayah needs these permissions to work properly.")
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 40)
            .padding(.bottom, 40)

            Spacer()

            // Permission cards
            VStack(spacing: 16) {
                PermissionCard(
                    icon: "mic.fill",
                    title: "Microphone",
                    description: "Required to verify your dhikr recitation",
                    isGranted: microphoneGranted,
                    onRequest: requestMicrophonePermission
                )

                PermissionCard(
                    icon: "bell.fill",
                    title: "Notifications",
                    description: "Get reminders and usage warnings",
                    isGranted: notificationsGranted,
                    onRequest: requestNotificationPermission
                )

                // Screen Time note
                ScreenTimeNote()
            }
            .padding(.horizontal, 24)

            Spacer()

            // Status message
            if microphoneGranted {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(WiqayahColors.success)

                    Text("Ready to go!")
                        .font(WiqayahFonts.body())
                        .foregroundColor(WiqayahColors.text)
                }
                .padding(.bottom, 24)
            }

            // Complete button
            Button(action: handleComplete) {
                if isRequestingPermissions {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: Constants.Sizing.buttonHeight)
                        .background(WiqayahColors.primary)
                        .cornerRadius(Constants.Sizing.cornerRadius)
                } else {
                    Text(microphoneGranted ? "Start Using Wiqayah" : "Enable & Continue")
                        .primaryButtonStyle()
                }
            }
            .disabled(isRequestingPermissions)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Skip button
            if !microphoneGranted {
                Button(action: onComplete) {
                    Text("Skip for Now")
                        .font(WiqayahFonts.body())
                        .foregroundColor(WiqayahColors.textSecondary)
                }
                .padding(.bottom, 40)
            } else {
                Spacer().frame(height: 56)
            }
        }
        .onAppear {
            checkCurrentPermissions()
        }
    }

    // MARK: - Permission Handling

    private func checkCurrentPermissions() {
        microphoneGranted = speechService.isAuthorized
        notificationsGranted = notificationService.isAuthorized
    }

    private func requestMicrophonePermission() {
        Task {
            isRequestingPermissions = true
            microphoneGranted = await speechService.requestAuthorization()
            isRequestingPermissions = false
            HapticManager.shared.lightImpact()
        }
    }

    private func requestNotificationPermission() {
        Task {
            isRequestingPermissions = true
            notificationsGranted = await notificationService.requestAuthorization()
            isRequestingPermissions = false
            HapticManager.shared.lightImpact()
        }
    }

    private func handleComplete() {
        if !microphoneGranted {
            requestMicrophonePermission()
        } else {
            onComplete()
        }
    }
}

// MARK: - Permission Card
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    let onRequest: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isGranted ? WiqayahColors.success.opacity(0.1) : WiqayahColors.primary.opacity(0.1))
                    .frame(width: 50, height: 50)

                Image(systemName: isGranted ? "checkmark" : icon)
                    .font(.system(size: 20))
                    .foregroundColor(isGranted ? WiqayahColors.success : WiqayahColors.primary)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(WiqayahFonts.body())
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)

                Text(description)
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            Spacer()

            // Status/Button
            if isGranted {
                Text("Enabled")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.success)
            } else {
                Button(action: onRequest) {
                    Text("Enable")
                        .font(WiqayahFonts.body(14))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(WiqayahColors.primary)
                        .cornerRadius(8)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(Constants.Sizing.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Screen Time Note
struct ScreenTimeNote: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "hourglass")
                .font(.system(size: 20))
                .foregroundColor(WiqayahColors.textSecondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Screen Time API")
                    .font(WiqayahFonts.body(14))
                    .fontWeight(.semibold)
                    .foregroundColor(WiqayahColors.text)

                Text("Real app blocking will be available in a future update. For now, you can test the dhikr flow using the simulator mode.")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }

            Spacer()
        }
        .padding(16)
        .background(WiqayahColors.background)
        .cornerRadius(Constants.Sizing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                .stroke(WiqayahColors.textSecondary.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    PermissionsView(onComplete: {})
        .background(WiqayahColors.background)
}
