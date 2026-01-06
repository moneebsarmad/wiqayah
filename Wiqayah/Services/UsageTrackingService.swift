import Foundation
import Combine

/// Tracks and manages app usage time
final class UsageTrackingService: ObservableObject {
    static let shared = UsageTrackingService()

    // MARK: - Published Properties
    @Published var todayTotalMinutes: Int = 0
    @Published var usagePercentage: Double = 0.0
    @Published var isApproachingLimit = false
    @Published var hasReachedLimit = false

    // MARK: - Private Properties
    private let dataManager = CoreDataManager.shared
    private let blockerService = AppBlockerService.shared
    private var updateTimer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupBindings()
        startPeriodicUpdates()
        updateStats()
    }

    // MARK: - Setup

    private func setupBindings() {
        // Update when blocker service changes
        blockerService.$simulatedUsageMinutes
            .sink { [weak self] _ in
                self?.updateStats()
            }
            .store(in: &cancellables)
    }

    private func startPeriodicUpdates() {
        // Update stats every minute
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }

    // MARK: - Stats Updates

    func updateStats() {
        todayTotalMinutes = blockerService.getTodayTotalUsage()
        usagePercentage = blockerService.getUsagePercentage()

        let limit = dataManager.currentUser.dailyLimitMinutes
        let warningThreshold = Double(limit) * 0.8 // 80% of limit

        isApproachingLimit = Double(todayTotalMinutes) >= warningThreshold && !hasReachedLimit
        hasReachedLimit = todayTotalMinutes >= limit
    }

    // MARK: - Usage Recording

    /// Record usage for a specific app
    func recordUsage(appId: String, minutes: Int) {
        dataManager.updateDailyStats(appBundleId: appId, minutes: minutes)
        updateStats()

        // Check for limit warnings
        checkLimitWarnings()
    }

    /// Get today's usage in minutes
    func getTodayUsage() -> Int {
        todayTotalMinutes
    }

    /// Get usage for a specific app today
    func getUsageByApp(appId: String) -> Int {
        dataManager.getUsageMinutes(for: appId)
    }

    /// Get remaining minutes for today
    func getRemainingMinutes() -> Int {
        blockerService.getRemainingMinutes()
    }

    /// Get daily limit in minutes
    func getDailyLimit() -> Int {
        dataManager.currentUser.dailyLimitMinutes
    }

    // MARK: - Limit Checking

    func canUnlock() -> Bool {
        !hasReachedLimit && dataManager.currentUser.canUnlock
    }

    private func checkLimitWarnings() {
        if isApproachingLimit && !hasReachedLimit {
            HapticManager.shared.warning()
            // NotificationService could trigger a warning notification here
        }

        if hasReachedLimit {
            HapticManager.shared.limitReached()
        }
    }

    // MARK: - Stats Queries

    /// Get usage breakdown by app for today
    func getTodayUsageByApp() -> [String: Int] {
        let stats = dataManager.getTodayStats()
        return stats.appUsageBreakdown
    }

    /// Get weekly stats
    func getWeeklyStats() -> [DailyStats] {
        dataManager.getWeeklyStats()
    }

    /// Get total usage for the week
    func getWeeklyTotalMinutes() -> Int {
        getWeeklyStats().weeklyTotalMinutes
    }

    /// Get average daily usage
    func getAverageDailyMinutes() -> Int {
        getWeeklyStats().averageDailyMinutes
    }

    /// Get current streak (days with dhikr completed)
    func getCurrentStreak() -> Int {
        dataManager.dailyStats.currentStreak
    }

    /// Get dhikr completion rate for today
    func getTodayDhikrRate() -> Double {
        dataManager.getTodayStats().dhikrCompletionRate
    }

    // MARK: - Formatting Helpers

    /// Format minutes as human-readable string
    func formatMinutes(_ minutes: Int) -> String {
        minutes.minutesToHoursMinutes
    }

    /// Get usage status message
    func getUsageStatusMessage() -> String {
        let remaining = getRemainingMinutes()
        let limit = getDailyLimit()

        if hasReachedLimit {
            return "Daily limit reached"
        } else if isApproachingLimit {
            return "Only \(remaining) minutes remaining"
        } else {
            return "\(todayTotalMinutes)/\(limit) minutes used"
        }
    }

    // MARK: - Reset

    func resetForNewDay() {
        dataManager.checkAndResetDaily()
        updateStats()
    }

    deinit {
        updateTimer?.invalidate()
    }
}
