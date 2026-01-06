import Foundation
import SwiftUI

/// Manages app blocking functionality
/// Note: Currently simulated. Will integrate with Screen Time API when developer account is ready.
final class AppBlockerService: ObservableObject {
    static let shared = AppBlockerService()

    // MARK: - Published Properties
    @Published var isBlockingEnabled = false
    @Published var currentlyBlockedApps: Set<String> = []
    @Published var activeSession: UsageSession?
    @Published var showingBlockerOverlay = false
    @Published var currentBlockedAppId: String?

    // MARK: - Private Properties
    private let dataManager = CoreDataManager.shared
    private var sessionTimer: Timer?
    private var sessionStartTime: Date?

    // MARK: - Simulated Properties
    @Published var isSimulatorMode = true
    @Published var simulatedUsageMinutes: Int = 0

    private init() {
        loadBlockedApps()
    }

    // MARK: - Public Methods

    /// Enable blocking for all selected apps
    func enableBlocking() {
        isBlockingEnabled = true
        loadBlockedApps()
    }

    /// Disable all blocking
    func disableBlocking() {
        isBlockingEnabled = false
        currentlyBlockedApps.removeAll()
        endCurrentSession()
    }

    /// Load blocked apps from data manager
    func loadBlockedApps() {
        let apps = dataManager.getBlockedApps()
        currentlyBlockedApps = Set(apps.map { $0.id })
    }

    /// Check if a specific app is blocked
    func isAppBlocked(bundleId: String) -> Bool {
        guard isBlockingEnabled else { return false }
        return currentlyBlockedApps.contains(bundleId)
    }

    /// Block a specific app
    func blockApp(bundleId: String) {
        dataManager.setAppBlocked(bundleId: bundleId, blocked: true)
        currentlyBlockedApps.insert(bundleId)
    }

    /// Unblock a specific app
    func unblockApp(bundleId: String) {
        dataManager.setAppBlocked(bundleId: bundleId, blocked: false)
        currentlyBlockedApps.remove(bundleId)
    }

    /// Temporarily unblock an app for specified duration (in minutes)
    func temporaryUnlock(bundleId: String, durationMinutes: Int) {
        currentlyBlockedApps.remove(bundleId)

        // Re-block after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(durationMinutes * 60)) { [weak self] in
            self?.currentlyBlockedApps.insert(bundleId)
        }
    }

    // MARK: - Session Management

    /// Start a usage session for an app
    func startSession(for bundleId: String) {
        endCurrentSession() // End any existing session

        activeSession = dataManager.startUsageSession(for: bundleId)
        sessionStartTime = Date()
        currentBlockedAppId = bundleId

        // Start timer to track usage
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateSessionDuration()
        }
    }

    /// End the current usage session
    func endCurrentSession() {
        sessionTimer?.invalidate()
        sessionTimer = nil

        if let session = activeSession {
            dataManager.endUsageSession(id: session.id)
        }

        activeSession = nil
        sessionStartTime = nil
        currentBlockedAppId = nil
    }

    /// Get current session duration in minutes
    func getCurrentSessionMinutes() -> Int {
        guard let startTime = sessionStartTime else { return 0 }
        return Int(Date().timeIntervalSince(startTime) / 60)
    }

    private func updateSessionDuration() {
        // This is called every minute to update any UI that needs real-time duration
        objectWillChange.send()
    }

    // MARK: - Simulated Blocking (For Testing)

    /// Simulate opening a blocked app (for testing without Screen Time API)
    func simulateAppOpen(bundleId: String) {
        guard isSimulatorMode else { return }

        if isAppBlocked(bundleId: bundleId) {
            currentBlockedAppId = bundleId
            showingBlockerOverlay = true
        }
    }

    /// Simulate unlocking an app after dhikr
    func simulateUnlock(bundleId: String, grantedMinutes: Int = 15) {
        guard isSimulatorMode else { return }

        showingBlockerOverlay = false
        startSession(for: bundleId)

        // Simulate session end after granted time
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(grantedMinutes * 60)) { [weak self] in
            self?.endCurrentSession()
            self?.simulatedUsageMinutes += grantedMinutes
        }
    }

    /// Add simulated usage time
    func addSimulatedUsage(minutes: Int) {
        simulatedUsageMinutes += minutes
    }

    /// Reset simulated usage
    func resetSimulatedUsage() {
        simulatedUsageMinutes = 0
    }

    // MARK: - Usage Queries

    /// Get today's total usage across all blocked apps
    func getTodayTotalUsage() -> Int {
        if isSimulatorMode {
            return simulatedUsageMinutes
        }
        return dataManager.getTodayUsageMinutes()
    }

    /// Get usage for a specific app today
    func getTodayUsage(for bundleId: String) -> Int {
        return dataManager.getUsageMinutes(for: bundleId)
    }

    /// Check if user has exceeded daily limit
    func hasExceededDailyLimit() -> Bool {
        let usage = getTodayTotalUsage()
        let limit = dataManager.currentUser.dailyLimitMinutes
        return usage >= limit
    }

    /// Get remaining minutes for today
    func getRemainingMinutes() -> Int {
        let usage = getTodayTotalUsage()
        let limit = dataManager.currentUser.dailyLimitMinutes
        return max(0, limit - usage)
    }

    /// Get usage percentage (0.0 - 1.0)
    func getUsagePercentage() -> Double {
        let usage = Double(getTodayTotalUsage())
        let limit = Double(dataManager.currentUser.dailyLimitMinutes)
        return min(1.0, usage / limit)
    }
}

// MARK: - Screen Time API Integration (Future)
extension AppBlockerService {
    /// Setup Screen Time API (to be implemented when developer account is ready)
    func setupScreenTimeAPI() {
        // TODO: Implement FamilyControls framework integration
        // 1. Request authorization
        // 2. Set up ManagedSettingsStore
        // 3. Configure ShieldConfigurationProvider
        // 4. Implement DeviceActivityMonitor
    }

    /// Request Screen Time authorization
    func requestScreenTimeAuthorization() async -> Bool {
        // TODO: Implement authorization request
        // return await AuthorizationCenter.shared.requestAuthorization(for: .individual)
        return false
    }
}
