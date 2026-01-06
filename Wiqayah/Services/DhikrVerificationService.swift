import Foundation

/// Handles dhikr verification logic
final class DhikrVerificationService: ObservableObject {
    static let shared = DhikrVerificationService()

    // MARK: - Published Properties
    @Published var currentRequirement: DhikrRequirement?
    @Published var detectedRepetitions = 0
    @Published var lastVerificationResult: VerificationResult?

    // MARK: - Private Properties
    private let dataManager = CoreDataManager.shared
    private let blockerService = AppBlockerService.shared

    private init() {}

    // MARK: - Get Required Dhikr

    /// Determine which dhikr is required based on usage and debt
    func getRequiredDhikr() -> DhikrRequirement {
        let minutesUsed = blockerService.getTodayTotalUsage()
        let user = dataManager.currentUser

        var requirement = getDhikrForUsageLevel(minutes: minutesUsed)

        // Apply debt multiplier if user has debt from emergency bypasses
        if user.hasDebt {
            requirement = requirement.withMultiplier(user.debtMultiplier)
        }

        currentRequirement = requirement
        return requirement
    }

    /// Get base dhikr requirement based on usage minutes
    private func getDhikrForUsageLevel(minutes: Int) -> DhikrRequirement {
        switch minutes {
        case 0..<Constants.DhikrThresholds.tier1MaxMinutes:
            // 0-20 min: Simple dhikr (Subhanallah 3x)
            return .subhanallah

        case Constants.DhikrThresholds.tier1MaxMinutes..<Constants.DhikrThresholds.tier2MaxMinutes:
            // 20-40 min: Ayat al-Kursi
            return .ayatAlKursi

        case Constants.DhikrThresholds.tier2MaxMinutes..<Constants.DhikrThresholds.tier3MaxMinutes:
            // 40-55 min: First 5 ayat of Surah al-Kahf
            return .surahKahfFirst5

        case Constants.DhikrThresholds.tier3MaxMinutes..<Constants.DhikrThresholds.tier4MaxMinutes:
            // 55-60 min: Full morning/evening adhkar
            return .morningAdhkar

        default:
            // Beyond 60 min: Should be hard blocked
            return .morningAdhkar
        }
    }

    // MARK: - Verification

    /// Verify spoken dhikr against requirement
    func verifyDhikr(spokenText: String, requirement: DhikrRequirement) -> VerificationResult {
        let normalizedSpoken = spokenText.normalizedArabic
        let normalizedExpected = requirement.arabic.normalizedArabic

        // Calculate similarity
        let similarity = normalizedSpoken.levenshteinSimilarity(to: normalizedExpected)

        // For repetition-based dhikr, count matches
        if requirement.repetitions > 1 {
            let repetitionsDetected = countRepetitions(in: spokenText, phrase: requirement.arabic)
            detectedRepetitions = repetitionsDetected

            if repetitionsDetected >= requirement.repetitions {
                lastVerificationResult = .success
                recordSuccessfulVerification(requirement: requirement, accuracy: similarity)
                return .success
            } else if repetitionsDetected > 0 {
                lastVerificationResult = .partial(detected: repetitionsDetected, required: requirement.repetitions)
                return .partial(detected: repetitionsDetected, required: requirement.repetitions)
            }
        }

        // For single recitation dhikr
        if similarity >= requirement.verificationThreshold {
            lastVerificationResult = .success
            recordSuccessfulVerification(requirement: requirement, accuracy: similarity)
            return .success
        } else if similarity >= (requirement.verificationThreshold - 0.2) {
            // Close but not quite
            lastVerificationResult = .partial(detected: 0, required: 1)
            return .partial(detected: 0, required: 1)
        }

        // Failed verification
        let reason: VerificationResult.FailureReason = normalizedSpoken.isEmpty ? .noSpeechDetected : .lowConfidence
        lastVerificationResult = .failure(reason: reason)
        return .failure(reason: reason)
    }

    /// Count how many times a phrase appears in the spoken text
    private func countRepetitions(in spokenText: String, phrase: String) -> Int {
        let normalizedSpoken = spokenText.normalizedArabic
        let normalizedPhrase = phrase.normalizedArabic

        // Simple count - in production, use more sophisticated matching
        var count = 0
        var searchRange = normalizedSpoken.startIndex..<normalizedSpoken.endIndex

        while let range = normalizedSpoken.range(of: normalizedPhrase, options: .literal, range: searchRange) {
            count += 1
            searchRange = range.upperBound..<normalizedSpoken.endIndex
        }

        // If exact matching fails, try similarity-based detection
        if count == 0 {
            // Split spoken text into segments and check each
            let words = normalizedSpoken.components(separatedBy: .whitespaces)
            let phraseWords = normalizedPhrase.components(separatedBy: .whitespaces)
            let phraseLength = phraseWords.count

            if words.count >= phraseLength {
                for i in 0...(words.count - phraseLength) {
                    let segment = words[i..<(i + phraseLength)].joined(separator: " ")
                    if segment.levenshteinSimilarity(to: normalizedPhrase) >= 0.7 {
                        count += 1
                    }
                }
            }
        }

        return count
    }

    // MARK: - Recording

    private func recordSuccessfulVerification(requirement: DhikrRequirement, accuracy: Double) {
        let session = DhikrSession(
            dhikrType: requirement.category.rawValue,
            dhikrName: requirement.name,
            wasSuccessful: true,
            attemptCount: 1,
            recognitionAccuracy: accuracy,
            appBundleId: blockerService.currentBlockedAppId
        )

        dataManager.recordDhikrSession(session)
        dataManager.recordUnlock()

        HapticManager.shared.unlockGranted()
    }

    func recordFailedAttempt(requirement: DhikrRequirement) {
        let session = DhikrSession(
            dhikrType: requirement.category.rawValue,
            dhikrName: requirement.name,
            wasSuccessful: false,
            attemptCount: 1,
            recognitionAccuracy: 0,
            appBundleId: blockerService.currentBlockedAppId
        )

        dataManager.recordDhikrSession(session)

        HapticManager.shared.error()
    }

    // MARK: - Emergency Bypass

    /// Check if emergency bypass is available
    func canUseEmergencyBypass() -> Bool {
        dataManager.currentUser.canUseEmergencyBypass
    }

    /// Use emergency bypass
    func useEmergencyBypass() {
        guard canUseEmergencyBypass() else { return }

        dataManager.recordEmergencyBypass()

        HapticManager.shared.warning()
    }

    /// Get remaining emergency bypasses
    func getRemainingBypasses() -> Int {
        dataManager.currentUser.emergencyBypassesRemaining
    }

    // MARK: - Unlock Check

    /// Check if user can unlock (hasn't exceeded limit)
    func canUnlock() -> Bool {
        let user = dataManager.currentUser

        // Check if premium or has unlocks remaining
        guard user.canUnlock else { return false }

        // Check if daily limit exceeded
        guard !blockerService.hasExceededDailyLimit() else { return false }

        return true
    }

    /// Get remaining unlocks for today
    func getRemainingUnlocks() -> Int {
        dataManager.currentUser.remainingUnlocks
    }

    // MARK: - Reset

    func reset() {
        currentRequirement = nil
        detectedRepetitions = 0
        lastVerificationResult = nil
    }
}
