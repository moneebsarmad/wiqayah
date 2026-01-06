import Foundation

/// Records a dhikr verification attempt
struct DhikrSession: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let dhikrType: String
    let dhikrName: String
    var wasSuccessful: Bool
    var attemptCount: Int
    var recognitionAccuracy: Double
    let appBundleId: String? // Which app triggered this dhikr

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        dhikrType: String,
        dhikrName: String,
        wasSuccessful: Bool = false,
        attemptCount: Int = 1,
        recognitionAccuracy: Double = 0.0,
        appBundleId: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.dhikrType = dhikrType
        self.dhikrName = dhikrName
        self.wasSuccessful = wasSuccessful
        self.attemptCount = attemptCount
        self.recognitionAccuracy = recognitionAccuracy
        self.appBundleId = appBundleId
    }

    // MARK: - Computed Properties

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    var accuracyPercentage: String {
        "\(Int(recognitionAccuracy * 100))%"
    }

    // MARK: - Mutating Methods

    mutating func recordAttempt(accuracy: Double) {
        attemptCount += 1
        recognitionAccuracy = max(recognitionAccuracy, accuracy)
    }

    mutating func markSuccessful(accuracy: Double) {
        wasSuccessful = true
        recognitionAccuracy = accuracy
    }
}

// MARK: - Session Statistics
extension Array where Element == DhikrSession {
    var successRate: Double {
        guard !isEmpty else { return 0 }
        let successful = filter { $0.wasSuccessful }.count
        return Double(successful) / Double(count)
    }

    var averageAccuracy: Double {
        guard !isEmpty else { return 0 }
        let total = reduce(0.0) { $0 + $1.recognitionAccuracy }
        return total / Double(count)
    }

    var averageAttempts: Double {
        guard !isEmpty else { return 0 }
        let total = reduce(0) { $0 + $1.attemptCount }
        return Double(total) / Double(count)
    }

    func sessions(for dhikrType: String) -> [DhikrSession] {
        filter { $0.dhikrType == dhikrType }
    }

    func todaySessions() -> [DhikrSession] {
        let calendar = Calendar.current
        return filter { calendar.isDateInToday($0.timestamp) }
    }
}
