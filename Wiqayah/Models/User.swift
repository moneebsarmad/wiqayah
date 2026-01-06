import Foundation

/// Represents the user profile with subscription and usage tracking
struct User: Identifiable, Codable {
    let id: UUID
    var isPremium: Bool
    var dailyLimitMinutes: Int
    var emergencyBypassesRemaining: Int
    var dhikrDebt: Int
    var unlocksUsedToday: Int
    let createdAt: Date
    var lastResetAt: Date

    // MARK: - Constants
    static let defaultDailyLimit = 60
    static let maxDailyLimit = 120
    static let minDailyLimit = 30
    static let maxEmergencyBypasses = 3
    static let freeUnlockLimit = 15
    static let maxDebtMultiplier = 3

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        isPremium: Bool = false,
        dailyLimitMinutes: Int = User.defaultDailyLimit,
        emergencyBypassesRemaining: Int = User.maxEmergencyBypasses,
        dhikrDebt: Int = 0,
        unlocksUsedToday: Int = 0,
        createdAt: Date = Date(),
        lastResetAt: Date = Date()
    ) {
        self.id = id
        self.isPremium = isPremium
        self.dailyLimitMinutes = dailyLimitMinutes
        self.emergencyBypassesRemaining = emergencyBypassesRemaining
        self.dhikrDebt = dhikrDebt
        self.unlocksUsedToday = unlocksUsedToday
        self.createdAt = createdAt
        self.lastResetAt = lastResetAt
    }

    // MARK: - Computed Properties
    var canUnlock: Bool {
        isPremium || unlocksUsedToday < User.freeUnlockLimit
    }

    var remainingUnlocks: Int {
        isPremium ? .max : max(0, User.freeUnlockLimit - unlocksUsedToday)
    }

    var hasDebt: Bool {
        dhikrDebt > 0
    }

    var debtMultiplier: Int {
        min(dhikrDebt + 1, User.maxDebtMultiplier)
    }

    var canUseEmergencyBypass: Bool {
        emergencyBypassesRemaining > 0
    }

    // MARK: - Mutating Methods
    mutating func useUnlock() {
        unlocksUsedToday += 1
    }

    mutating func useEmergencyBypass() {
        guard canUseEmergencyBypass else { return }
        emergencyBypassesRemaining -= 1
        dhikrDebt = min(dhikrDebt + 1, User.maxDebtMultiplier - 1)
    }

    mutating func completeDhikr() {
        if dhikrDebt > 0 {
            dhikrDebt -= 1
        }
    }

    mutating func resetDaily(at fajrTime: Date) {
        unlocksUsedToday = 0
        emergencyBypassesRemaining = User.maxEmergencyBypasses
        dhikrDebt = 0
        lastResetAt = fajrTime
    }
}
