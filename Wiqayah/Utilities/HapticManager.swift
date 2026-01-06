import UIKit

/// Manages haptic feedback throughout the app
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // MARK: - Notification Feedback

    /// Success feedback - use after successful dhikr verification
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)
    }

    /// Error feedback - use for failed verification
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }

    /// Warning feedback - use for limit approaching
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.warning)
    }

    // MARK: - Impact Feedback

    /// Light impact - use for button taps
    func lightImpact() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Medium impact - use for selections
    func mediumImpact() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Heavy impact - use for significant actions
    func heavyImpact() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Soft impact - iOS 13+
    func softImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Rigid impact - iOS 13+
    func rigidImpact() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
        generator.impactOccurred()
    }

    // MARK: - Selection Feedback

    /// Selection changed - use for picker/list selections
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Recording started pattern
    func recordingStarted() {
        mediumImpact()
    }

    /// Recording stopped pattern
    func recordingStopped() {
        lightImpact()
    }

    /// Unlock granted pattern
    func unlockGranted() {
        DispatchQueue.main.async {
            self.success()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.lightImpact()
        }
    }

    /// Limit reached pattern
    func limitReached() {
        DispatchQueue.main.async {
            self.error()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.heavyImpact()
        }
    }

    /// Countdown tick
    func tick() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.5)
    }
}
