import SwiftUI

/// Recording screen with waveform visualization
struct RecordingView: View {
    let requirement: DhikrRequirement
    var onComplete: (String) -> Void
    var onCancel: () -> Void

    @StateObject private var speechService = SpeechRecognitionService.shared

    @State private var isRecording = false
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Text("Recite Now")
                    .font(WiqayahFonts.header(24))
                    .foregroundColor(.white)

                Text(MotivationalMessages.randomDhikrEncouragement())
                    .font(WiqayahFonts.body())
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            // Dhikr text
            VStack(spacing: 16) {
                Text(requirement.arabic)
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                Text(requirement.transliteration)
                    .font(WiqayahFonts.body(18))
                    .foregroundColor(.white.opacity(0.8))

                if requirement.repetitions > 1 {
                    Text("Repeat \(requirement.repetitions) times")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
            }

            Spacer()

            // Waveform visualization
            VStack(spacing: 24) {
                CircularWaveformView(
                    audioLevel: $speechService.audioLevel,
                    isRecording: isRecording,
                    size: 180,
                    color: .white
                )

                // Recording status
                HStack(spacing: 8) {
                    if isRecording {
                        RecordingPulseView(isRecording: true, color: .red)

                        Text("Listening...")
                            .font(WiqayahFonts.body())
                            .foregroundColor(.white)

                        Text(formatDuration(recordingDuration))
                            .font(WiqayahFonts.body())
                            .foregroundColor(.white.opacity(0.7))
                            .monospacedDigit()
                    } else {
                        Text("Tap the button to start")
                            .font(WiqayahFonts.body())
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                // Recognized text preview
                if !speechService.recognizedText.isEmpty {
                    VStack(spacing: 4) {
                        Text("Detected:")
                            .font(WiqayahFonts.caption())
                            .foregroundColor(.white.opacity(0.5))

                        Text(speechService.recognizedText)
                            .font(WiqayahFonts.body())
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .padding(.horizontal, 32)
                    }
                }
            }

            Spacer()

            // Control buttons
            VStack(spacing: 16) {
                // Main record/stop button
                Button(action: toggleRecording) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 80, height: 80)

                        if isRecording {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.red)
                                .frame(width: 32, height: 32)
                        } else {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 60, height: 60)
                        }
                    }
                }

                Text(isRecording ? "Tap to stop" : "Tap to record")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(.white.opacity(0.6))

                // Cancel button
                Button(action: handleCancel) {
                    Text("Cancel")
                        .font(WiqayahFonts.body())
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 40)
        }
        .onDisappear {
            stopRecording()
        }
    }

    // MARK: - Recording Control

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        HapticManager.shared.recordingStarted()

        speechService.startRecording()
        isRecording = true
        recordingDuration = 0

        // Start duration timer
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
    }

    private func stopRecording() {
        guard isRecording else { return }

        timer?.invalidate()
        timer = nil
        isRecording = false

        Task {
            let recognizedText = await speechService.stopRecording()
            await MainActor.run {
                onComplete(recognizedText)
            }
        }
    }

    private func handleCancel() {
        speechService.cancelRecording()
        timer?.invalidate()
        timer = nil
        isRecording = false
        onCancel()
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let seconds = Int(duration)
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        WiqayahColors.primary
            .ignoresSafeArea()

        RecordingView(
            requirement: .subhanallah,
            onComplete: { _ in },
            onCancel: {}
        )
    }
}
