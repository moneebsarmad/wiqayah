import Foundation
import UserNotifications

/// Manages local notifications for usage warnings and reminders
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    // MARK: - Published Properties
    @Published var isAuthorized = false

    // MARK: - Notification Identifiers
    private enum NotificationID {
        static let usageWarning50 = "wiqayah.usage.warning.50"
        static let usageWarning80 = "wiqayah.usage.warning.80"
        static let limitReached = "wiqayah.limit.reached"
        static let fajrReminder = "wiqayah.fajr.reminder"
        static let dailyReminder = "wiqayah.daily.reminder"
        static let streakReminder = "wiqayah.streak.reminder"
    }

    private init() {
        checkAuthorization()
    }

    // MARK: - Authorization

    /// Request notification permission
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])

            await MainActor.run {
                isAuthorized = granted
            }

            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    /// Check current authorization status
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    // MARK: - Usage Warnings

    /// Schedule warning when usage reaches 50%
    func scheduleUsageWarning50(minutesUsed: Int, limit: Int) {
        guard isAuthorized else { return }

        let remaining = limit - minutesUsed

        let content = UNMutableNotificationContent()
        content.title = "Halfway There"
        content.body = "You've used half your daily limit. \(remaining) minutes remaining."
        content.sound = .default
        content.categoryIdentifier = "USAGE_WARNING"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.usageWarning50,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Schedule warning when usage reaches 80%
    func scheduleUsageWarning80(minutesUsed: Int, limit: Int) {
        guard isAuthorized else { return }

        let remaining = limit - minutesUsed

        let content = UNMutableNotificationContent()
        content.title = "Almost at Limit"
        content.body = "Only \(remaining) minutes remaining today. Consider taking a break."
        content.sound = .default
        content.categoryIdentifier = "USAGE_WARNING"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.usageWarning80,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// Notify when limit is reached
    func notifyLimitReached(nextReset: Date) {
        guard isAuthorized else { return }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        let content = UNMutableNotificationContent()
        content.title = "Daily Limit Reached"
        content.body = "Your screen time limit is complete. Resets at Fajr (\(formatter.string(from: nextReset)))."
        content.sound = .default
        content.categoryIdentifier = "LIMIT_REACHED"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: NotificationID.limitReached,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Fajr Reminder

    /// Schedule daily Fajr reminder
    func scheduleFajrReminder(fajrTime: Date) {
        guard isAuthorized else { return }

        // Cancel existing reminder
        cancelNotification(id: NotificationID.fajrReminder)

        let content = UNMutableNotificationContent()
        content.title = "New Day, Fresh Start"
        content.body = "Your daily limits have reset. May your day be blessed."
        content.sound = .default
        content.categoryIdentifier = "FAJR_REMINDER"

        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: fajrTime)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.fajrReminder,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Daily Reminder

    /// Schedule daily reminder at specific time
    func scheduleDailyReminder(hour: Int, minute: Int) {
        guard isAuthorized else { return }

        cancelNotification(id: NotificationID.dailyReminder)

        let content = UNMutableNotificationContent()
        content.title = "Daily Check-in"
        content.body = "How was your screen time today? Remember your goals."
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.dailyReminder,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Streak Reminder

    /// Remind user to maintain their streak
    func scheduleStreakReminder(currentStreak: Int) {
        guard isAuthorized, currentStreak > 0 else { return }

        cancelNotification(id: NotificationID.streakReminder)

        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak!"
        content.body = "You have a \(currentStreak)-day streak. Keep it going!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"

        // Schedule for 8 PM
        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: NotificationID.streakReminder,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Management

    /// Cancel a specific notification
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    /// Get all pending notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await UNUserNotificationCenter.current().pendingNotificationRequests()
    }

    // MARK: - Notification Categories

    /// Setup notification categories and actions
    func setupNotificationCategories() {
        // Usage warning category
        let viewStatsAction = UNNotificationAction(
            identifier: "VIEW_STATS",
            title: "View Stats",
            options: .foreground
        )

        let usageCategory = UNNotificationCategory(
            identifier: "USAGE_WARNING",
            actions: [viewStatsAction],
            intentIdentifiers: []
        )

        // Limit reached category
        let limitCategory = UNNotificationCategory(
            identifier: "LIMIT_REACHED",
            actions: [viewStatsAction],
            intentIdentifiers: []
        )

        // Fajr reminder category
        let fajrCategory = UNNotificationCategory(
            identifier: "FAJR_REMINDER",
            actions: [],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            usageCategory,
            limitCategory,
            fajrCategory
        ])
    }
}
