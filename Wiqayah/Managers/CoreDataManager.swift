import Foundation
import SwiftUI

/// Manages local data persistence using UserDefaults and file storage
/// Note: This is a simplified version. For production, consider using Core Data or SwiftData
final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager()

    // MARK: - Published Properties
    @Published var currentUser: User
    @Published var blockedApps: [BlockedApp]
    @Published var usageSessions: [UsageSession]
    @Published var dailyStats: [DailyStats]
    @Published var dhikrSessions: [DhikrSession]

    // MARK: - UserDefaults Keys
    private enum Keys {
        static let user = "wiqayah_user"
        static let blockedApps = "wiqayah_blocked_apps"
        static let usageSessions = "wiqayah_usage_sessions"
        static let dailyStats = "wiqayah_daily_stats"
        static let dhikrSessions = "wiqayah_dhikr_sessions"
        static let hasCompletedOnboarding = "wiqayah_has_completed_onboarding"
    }

    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization
    private init() {
        // Load user or create default
        if let userData = defaults.data(forKey: Keys.user),
           let user = try? decoder.decode(User.self, from: userData) {
            self.currentUser = user
        } else {
            self.currentUser = User()
        }

        // Load blocked apps or use defaults
        if let appsData = defaults.data(forKey: Keys.blockedApps),
           let apps = try? decoder.decode([BlockedApp].self, from: appsData) {
            self.blockedApps = apps
        } else {
            self.blockedApps = BlockedApp.supportedApps
        }

        // Load usage sessions
        if let sessionsData = defaults.data(forKey: Keys.usageSessions),
           let sessions = try? decoder.decode([UsageSession].self, from: sessionsData) {
            self.usageSessions = sessions
        } else {
            self.usageSessions = []
        }

        // Load daily stats
        if let statsData = defaults.data(forKey: Keys.dailyStats),
           let stats = try? decoder.decode([DailyStats].self, from: statsData) {
            self.dailyStats = stats
        } else {
            self.dailyStats = []
        }

        // Load dhikr sessions
        if let dhikrData = defaults.data(forKey: Keys.dhikrSessions),
           let sessions = try? decoder.decode([DhikrSession].self, from: dhikrData) {
            self.dhikrSessions = sessions
        } else {
            self.dhikrSessions = []
        }

        // Check if we need to reset for today
        checkAndResetDaily()
    }

    // MARK: - User Operations

    func saveUser() {
        if let data = try? encoder.encode(currentUser) {
            defaults.set(data, forKey: Keys.user)
        }
    }

    func updateUser(_ user: User) {
        currentUser = user
        saveUser()
    }

    func setDailyLimit(_ minutes: Int) {
        currentUser.dailyLimitMinutes = min(max(minutes, User.minDailyLimit), User.maxDailyLimit)
        saveUser()
    }

    func setPremiumStatus(_ isPremium: Bool) {
        currentUser.isPremium = isPremium
        saveUser()
    }

    // MARK: - Blocked Apps Operations

    func saveBlockedApps() {
        if let data = try? encoder.encode(blockedApps) {
            defaults.set(data, forKey: Keys.blockedApps)
        }
    }

    func toggleAppBlock(bundleId: String) {
        if let index = blockedApps.firstIndex(where: { $0.id == bundleId }) {
            blockedApps[index].isBlocked.toggle()
            saveBlockedApps()
        }
    }

    func setAppBlocked(bundleId: String, blocked: Bool) {
        if let index = blockedApps.firstIndex(where: { $0.id == bundleId }) {
            blockedApps[index].isBlocked = blocked
            saveBlockedApps()
        }
    }

    func getBlockedApps() -> [BlockedApp] {
        blockedApps.filter { $0.isBlocked }
    }

    // MARK: - Usage Session Operations

    func saveUsageSessions() {
        if let data = try? encoder.encode(usageSessions) {
            defaults.set(data, forKey: Keys.usageSessions)
        }
    }

    func startUsageSession(for appBundleId: String) -> UsageSession {
        let session = UsageSession(appBundleId: appBundleId)
        usageSessions.append(session)
        saveUsageSessions()
        return session
    }

    func endUsageSession(id: UUID) {
        if let index = usageSessions.firstIndex(where: { $0.id == id }) {
            usageSessions[index].end()
            saveUsageSessions()

            // Update daily stats
            let session = usageSessions[index]
            updateDailyStats(appBundleId: session.appBundleId, minutes: session.durationMinutes)
        }
    }

    func getTodayUsageMinutes() -> Int {
        usageSessions.todaySessions().totalMinutes
    }

    func getUsageMinutes(for appBundleId: String) -> Int {
        usageSessions.todaySessions().sessions(for: appBundleId).totalMinutes
    }

    // MARK: - Daily Stats Operations

    func saveDailyStats() {
        if let data = try? encoder.encode(dailyStats) {
            defaults.set(data, forKey: Keys.dailyStats)
        }
    }

    func getTodayStats() -> DailyStats {
        let today = Date().startOfDay
        if let stats = dailyStats.first(where: { $0.date.isSameDay(as: today) }) {
            return stats
        }
        let newStats = DailyStats(date: today)
        dailyStats.append(newStats)
        saveDailyStats()
        return newStats
    }

    func updateDailyStats(appBundleId: String, minutes: Int) {
        var stats = getTodayStats()
        stats.addUsage(appBundleId: appBundleId, minutes: minutes)

        if let index = dailyStats.firstIndex(where: { $0.date.isSameDay(as: stats.date) }) {
            dailyStats[index] = stats
        }
        saveDailyStats()
    }

    func recordUnlock() {
        currentUser.useUnlock()
        saveUser()

        var stats = getTodayStats()
        stats.recordUnlock()
        if let index = dailyStats.firstIndex(where: { $0.date.isSameDay(as: stats.date) }) {
            dailyStats[index] = stats
        }
        saveDailyStats()
    }

    func recordEmergencyBypass() {
        currentUser.useEmergencyBypass()
        saveUser()

        var stats = getTodayStats()
        stats.recordBypass()
        if let index = dailyStats.firstIndex(where: { $0.date.isSameDay(as: stats.date) }) {
            dailyStats[index] = stats
        }
        saveDailyStats()
    }

    func getWeeklyStats() -> [DailyStats] {
        [DailyStats].lastWeek(from: dailyStats)
    }

    // MARK: - Dhikr Session Operations

    func saveDhikrSessions() {
        if let data = try? encoder.encode(dhikrSessions) {
            defaults.set(data, forKey: Keys.dhikrSessions)
        }
    }

    func recordDhikrSession(_ session: DhikrSession) {
        dhikrSessions.append(session)
        saveDhikrSessions()

        if session.wasSuccessful {
            currentUser.completeDhikr()
            saveUser()

            var stats = getTodayStats()
            stats.recordDhikrCompletion()
            if let index = dailyStats.firstIndex(where: { $0.date.isSameDay(as: stats.date) }) {
                dailyStats[index] = stats
            }
            saveDailyStats()
        }
    }

    // MARK: - Onboarding

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }

    // MARK: - Daily Reset

    func checkAndResetDaily() {
        // Check if we've passed the last reset time
        let now = Date()
        if !currentUser.lastResetAt.isToday {
            // Reset daily counters
            currentUser.unlocksUsedToday = 0
            currentUser.emergencyBypassesRemaining = User.maxEmergencyBypasses
            currentUser.dhikrDebt = 0
            currentUser.lastResetAt = now
            saveUser()
        }
    }

    func resetForFajr(fajrTime: Date) {
        currentUser.resetDaily(at: fajrTime)
        saveUser()
    }

    // MARK: - Clear All Data

    func clearAllData() {
        defaults.removeObject(forKey: Keys.user)
        defaults.removeObject(forKey: Keys.blockedApps)
        defaults.removeObject(forKey: Keys.usageSessions)
        defaults.removeObject(forKey: Keys.dailyStats)
        defaults.removeObject(forKey: Keys.dhikrSessions)
        defaults.removeObject(forKey: Keys.hasCompletedOnboarding)

        currentUser = User()
        blockedApps = BlockedApp.supportedApps
        usageSessions = []
        dailyStats = []
        dhikrSessions = []
    }
}
