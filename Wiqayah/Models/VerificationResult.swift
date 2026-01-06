import Foundation

/// Result of dhikr speech verification
enum VerificationResult: Equatable {
    case success
    case partial(detected: Int, required: Int)
    case failure(reason: FailureReason)

    enum FailureReason: String, Equatable {
        case noSpeechDetected = "No speech detected"
        case lowConfidence = "Could not understand clearly"
        case wrongPhrase = "Incorrect phrase detected"
        case networkError = "Network error occurred"
        case microphoneError = "Microphone access error"
    }

    // MARK: - Computed Properties

    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }

    var isPartial: Bool {
        if case .partial = self {
            return true
        }
        return false
    }

    var isFailure: Bool {
        if case .failure = self {
            return true
        }
        return false
    }

    /// User-friendly message
    var message: String {
        switch self {
        case .success:
            return "بَارَكَ ٱللَّٰهُ فِيكَ\nBarakallahu feek"
        case .partial(let detected, let required):
            return "\(detected)/\(required) detected. Please repeat \(required - detected) more time(s)."
        case .failure(let reason):
            return reason.rawValue
        }
    }

    /// Whether the user should retry
    var shouldRetry: Bool {
        switch self {
        case .success:
            return false
        case .partial, .failure:
            return true
        }
    }

    /// Remaining count for partial matches
    var remainingCount: Int? {
        if case .partial(let detected, let required) = self {
            return required - detected
        }
        return nil
    }
}

// MARK: - Verification Accuracy
struct VerificationAccuracy {
    let overallScore: Double
    let wordMatches: [WordMatch]

    struct WordMatch {
        let expected: String
        let recognized: String
        let confidence: Double
    }

    var isAcceptable: Bool {
        overallScore >= 0.7
    }

    var percentageString: String {
        "\(Int(overallScore * 100))%"
    }
}
