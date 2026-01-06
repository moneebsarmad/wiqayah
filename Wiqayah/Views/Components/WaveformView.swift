import SwiftUI

/// Animated waveform visualization for audio recording
struct WaveformView: View {
    @Binding var audioLevel: Float
    var barCount: Int = 40
    var color: Color = WiqayahColors.primary
    var isRecording: Bool = true

    @State private var animationPhase: Double = 0

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<barCount, id: \.self) { index in
                WaveformBar(
                    height: barHeight(for: index),
                    color: color,
                    isAnimating: isRecording
                )
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func barHeight(for index: Int) -> CGFloat {
        if !isRecording {
            return 0.1
        }

        let normalizedIndex = Double(index) / Double(barCount)
        let wave = sin((normalizedIndex * 4 * .pi) + animationPhase)
        let baseHeight = 0.3 + (Double(audioLevel) * 0.5)
        let variation = (wave + 1) / 2 * 0.3

        return CGFloat(min(1, max(0.1, baseHeight + variation)))
    }

    private func startAnimation() {
        withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
            animationPhase = .pi * 2
        }
    }
}

// MARK: - Single Waveform Bar
struct WaveformBar: View {
    let height: CGFloat // 0.0 to 1.0
    var color: Color = WiqayahColors.primary
    var isAnimating: Bool = true
    var maxHeight: CGFloat = 60

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 4, height: actualHeight)
            .animation(.easeInOut(duration: 0.1), value: height)
    }

    private var actualHeight: CGFloat {
        let minHeight: CGFloat = 4
        return minHeight + (maxHeight - minHeight) * height
    }
}

// MARK: - Circular Waveform
struct CircularWaveformView: View {
    @Binding var audioLevel: Float
    var isRecording: Bool = true
    var size: CGFloat = 200
    var color: Color = WiqayahColors.primary

    @State private var pulseScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Outer pulse rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(color.opacity(0.2 - Double(index) * 0.05), lineWidth: 2)
                    .scaleEffect(pulseScale + CGFloat(index) * 0.1)
            }

            // Main circle with audio level
            Circle()
                .fill(color.opacity(0.1))
                .scaleEffect(1.0 + CGFloat(audioLevel) * 0.2)

            // Inner circle
            Circle()
                .stroke(color, lineWidth: 3)
                .scaleEffect(0.9 + CGFloat(audioLevel) * 0.1)

            // Microphone icon
            Image(systemName: isRecording ? "waveform" : "mic.fill")
                .font(.system(size: size * 0.2, weight: .medium))
                .foregroundColor(color)
                .scaleEffect(isRecording ? 1.0 + CGFloat(audioLevel) * 0.2 : 1.0)
        }
        .frame(width: size, height: size)
        .onAppear {
            if isRecording {
                startPulseAnimation()
            }
        }
        .onChange(of: isRecording) { _, newValue in
            if newValue {
                startPulseAnimation()
            }
        }
    }

    private func startPulseAnimation() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.1
        }
    }
}

// MARK: - Simple Pulse Indicator
struct RecordingPulseView: View {
    var isRecording: Bool = true
    var color: Color = WiqayahColors.error

    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 12, height: 12)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.7 : 1.0)
            .animation(
                isRecording ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : .default,
                value: isPulsing
            )
            .onAppear {
                isPulsing = isRecording
            }
            .onChange(of: isRecording) { _, newValue in
                isPulsing = newValue
            }
    }
}

// MARK: - Recording Status View
struct RecordingStatusView: View {
    @Binding var audioLevel: Float
    var isRecording: Bool
    var statusText: String = "Listening..."

    var body: some View {
        VStack(spacing: 20) {
            CircularWaveformView(
                audioLevel: $audioLevel,
                isRecording: isRecording
            )

            HStack(spacing: 8) {
                RecordingPulseView(isRecording: isRecording)

                Text(statusText)
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.text)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var audioLevel: Float = 0.5

        var body: some View {
            VStack(spacing: 40) {
                WaveformView(audioLevel: $audioLevel)
                    .frame(height: 60)
                    .padding()

                CircularWaveformView(audioLevel: $audioLevel)

                RecordingStatusView(audioLevel: $audioLevel, isRecording: true)

                Slider(value: $audioLevel, in: 0...1)
                    .padding()
            }
            .padding()
            .background(WiqayahColors.background)
        }
    }

    return PreviewWrapper()
}
