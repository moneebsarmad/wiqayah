import Foundation

/// Represents a single usage session for a blocked app
struct UsageSession: Identifiable, Codable {
    let id: UUID
    let appBundleId: String
    let startTime: Date
    var endTime: Date?

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        appBundleId: String,
        startTime: Date = Date(),
        endTime: Date? = nil
    ) {
        self.id = id
        self.appBundleId = appBundleId
        self.startTime = startTime
        self.endTime = endTime
    }

    // MARK: - Computed Properties

    /// Duration in seconds
    var durationSeconds: Int {
        let end = endTime ?? Date()
        return Int(end.timeIntervalSince(startTime))
    }

    /// Duration in minutes (rounded)
    var durationMinutes: Int {
        durationSeconds / 60
    }

    /// Whether the session is currently active
    var isActive: Bool {
        endTime == nil
    }

    // MARK: - Mutating Methods
    mutating func end() {
        endTime = Date()
    }
}

// MARK: - UsageSession Collection Extensions
extension Array where Element == UsageSession {
    /// Total duration of all sessions in minutes
    var totalMinutes: Int {
        reduce(0) { $0 + $1.durationMinutes }
    }

    /// Total duration of all sessions in seconds
    var totalSeconds: Int {
        reduce(0) { $0 + $1.durationSeconds }
    }

    /// Sessions for a specific app
    func sessions(for appBundleId: String) -> [UsageSession] {
        filter { $0.appBundleId == appBundleId }
    }

    /// Sessions for today only
    func todaySessions() -> [UsageSession] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return filter { calendar.isDate($0.startTime, inSameDayAs: today) }
    }
}
