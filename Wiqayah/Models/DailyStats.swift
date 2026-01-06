import Foundation

/// Tracks daily usage statistics
struct DailyStats: Identifiable, Codable {
    let id: UUID
    let date: Date
    var totalMinutesUsed: Int
    var unlocksUsed: Int
    var dhikrCompleted: Int
    var bypassesUsed: Int
    var appUsageBreakdown: [String: Int] // appBundleId -> minutes

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalMinutesUsed: Int = 0,
        unlocksUsed: Int = 0,
        dhikrCompleted: Int = 0,
        bypassesUsed: Int = 0,
        appUsageBreakdown: [String: Int] = [:]
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.totalMinutesUsed = totalMinutesUsed
        self.unlocksUsed = unlocksUsed
        self.dhikrCompleted = dhikrCompleted
        self.bypassesUsed = bypassesUsed
        self.appUsageBreakdown = appUsageBreakdown
    }

    // MARK: - Computed Properties

    /// Formatted date string
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    /// Day of week (e.g., "Mon", "Tue")
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    /// Dhikr completion rate (0.0 - 1.0)
    var dhikrCompletionRate: Double {
        guard unlocksUsed > 0 else { return 1.0 }
        return Double(dhikrCompleted) / Double(unlocksUsed)
    }

    /// Most used app bundle ID
    var mostUsedApp: String? {
        appUsageBreakdown.max(by: { $0.value < $1.value })?.key
    }

    // MARK: - Mutating Methods

    mutating func addUsage(appBundleId: String, minutes: Int) {
        totalMinutesUsed += minutes
        appUsageBreakdown[appBundleId, default: 0] += minutes
    }

    mutating func recordUnlock() {
        unlocksUsed += 1
    }

    mutating func recordDhikrCompletion() {
        dhikrCompleted += 1
    }

    mutating func recordBypass() {
        bypassesUsed += 1
    }
}

// MARK: - Weekly Stats Helper
extension Array where Element == DailyStats {
    /// Get stats for the last 7 days
    static func lastWeek(from stats: [DailyStats]) -> [DailyStats] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<7).compactMap { daysAgo in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: today) else {
                return nil
            }
            return stats.first { calendar.isDate($0.date, inSameDayAs: date) }
                ?? DailyStats(date: date)
        }.reversed()
    }

    /// Total minutes for the week
    var weeklyTotalMinutes: Int {
        reduce(0) { $0 + $1.totalMinutesUsed }
    }

    /// Average daily minutes
    var averageDailyMinutes: Int {
        guard !isEmpty else { return 0 }
        return weeklyTotalMinutes / count
    }

    /// Current streak (consecutive days with dhikr completion)
    var currentStreak: Int {
        var streak = 0
        let sorted = sorted { $0.date > $1.date }

        for stat in sorted {
            if stat.dhikrCompleted > 0 {
                streak += 1
            } else {
                break
            }
        }

        return streak
    }
}
