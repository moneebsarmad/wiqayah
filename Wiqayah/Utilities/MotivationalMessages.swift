import Foundation

/// Provides rotating motivational messages after dhikr completion
struct MotivationalMessages {

    // MARK: - Post-Dhikr Messages

    static let postDhikrMessages: [String] = [
        "You have {remaining} minutes left. Use them wisely.",
        "Remember: Allah is watching even in private.",
        "The time you spend in dhikr is never wasted.",
        "Guard your eyes, guard your heart.",
        "Every scroll avoided is a victory.",
        "Your future self will thank you.",
        "Quality over quantity. Choose content wisely.",
        "This pause was a mercy. Be grateful.",
        "You are stronger than your urges.",
        "Make your screen time meaningful.",
        "Remember why you started using Wiqayah.",
        "Small victories lead to big changes.",
        "Your attention is precious. Spend it wisely.",
        "This moment of remembrance was blessed.",
        "Stay mindful. Stay focused. Stay protected.",
    ]

    // MARK: - Limit Warning Messages

    static let limitWarningMessages: [String] = [
        "You've used most of your daily allowance.",
        "Time is running low. Be mindful.",
        "Consider taking a break from the screen.",
        "Perhaps it's time for something else?",
        "Your limit is approaching. Reflect on your usage.",
    ]

    // MARK: - Limit Reached Messages

    static let limitReachedMessages: [String] = [
        "Daily limit reached. Time for other pursuits.",
        "Your screen time is complete for today.",
        "Allah has given you another day. Use it well.",
        "Step away from the screen. Find peace elsewhere.",
        "Tomorrow is a new day with new opportunities.",
    ]

    // MARK: - Streak Messages

    static func streakMessage(days: Int) -> String {
        switch days {
        case 0:
            return "Start your streak today!"
        case 1:
            return "1 day streak! Keep it going!"
        case 2...6:
            return "\(days) day streak! You're building a habit."
        case 7:
            return "One week streak! Amazing dedication."
        case 8...29:
            return "\(days) day streak! You're unstoppable."
        case 30:
            return "One month streak! Incredible discipline."
        default:
            return "\(days) day streak! Mashallah!"
        }
    }

    // MARK: - Random Message Getters

    static func randomPostDhikrMessage(remainingMinutes: Int) -> String {
        let message = postDhikrMessages.randomElement() ?? postDhikrMessages[0]
        return message.replacingOccurrences(of: "{remaining}", with: "\(remainingMinutes)")
    }

    static func randomLimitWarning() -> String {
        limitWarningMessages.randomElement() ?? limitWarningMessages[0]
    }

    static func randomLimitReached() -> String {
        limitReachedMessages.randomElement() ?? limitReachedMessages[0]
    }

    // MARK: - Dhikr Encouragement

    static let dhikrEncouragement: [String] = [
        "Speak clearly and from the heart.",
        "Take your time. Quality matters.",
        "Remember the meaning as you recite.",
        "This is a moment between you and Allah.",
        "Your voice carries your intention.",
    ]

    static func randomDhikrEncouragement() -> String {
        dhikrEncouragement.randomElement() ?? dhikrEncouragement[0]
    }

    // MARK: - Time-Based Greetings

    static func greeting(for date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 4..<7:
            return "Blessed Fajr time"
        case 7..<12:
            return "Good morning"
        case 12..<15:
            return "Good afternoon"
        case 15..<18:
            return "Good afternoon"
        case 18..<20:
            return "Good evening"
        default:
            return "Good evening"
        }
    }

    // MARK: - Arabic Phrases

    static let barakallah = "بَارَكَ ٱللَّٰهُ فِيكَ"
    static let barakallahTransliteration = "Barakallahu feek"
    static let barakallahMeaning = "May Allah bless you"

    static let mashallah = "مَا شَاءَ ٱللَّٰهُ"
    static let jazakallah = "جَزَاكَ ٱللَّٰهُ خَيْرًا"
}
