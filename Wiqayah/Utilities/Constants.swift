import SwiftUI

// MARK: - App Constants
enum Constants {
    // MARK: - API Keys (Replace with actual keys)
    enum API {
        static let googleSpeechToTextKey = "YOUR_GOOGLE_SPEECH_API_KEY"
        static let googleSpeechEndpoint = "https://speech.googleapis.com/v1/speech:recognize"
    }

    // MARK: - StoreKit Product IDs
    enum StoreKit {
        static let premiumMonthlyProductID = "com.wiqayah.premium.monthly"
        static let premiumYearlyProductID = "com.wiqayah.premium.yearly"
    }

    // MARK: - Usage Limits
    enum Limits {
        static let freeUnlocksPerDay = 15
        static let defaultDailyMinutes = 60
        static let minDailyMinutes = 30
        static let maxDailyMinutes = 120
        static let emergencyBypassesPerWeek = 3
        static let maxDebtMultiplier = 3
    }

    // MARK: - Dhikr Thresholds
    enum DhikrThresholds {
        static let tier1MaxMinutes = 20   // 0-20 min: Simple dhikr
        static let tier2MaxMinutes = 40   // 20-40 min: Ayat al-Kursi
        static let tier3MaxMinutes = 55   // 40-55 min: First 5 ayat of Kahf
        static let tier4MaxMinutes = 60   // 55-60 min: Full adhkar set
    }

    // MARK: - Speech Recognition
    enum SpeechRecognition {
        static let defaultThreshold: Double = 0.7
        static let strictThreshold: Double = 0.75
        static let sampleRate: Int = 16000
        static let languageCode = "ar-SA"
        static let alternativeLanguages = ["ar-EG", "ar-MA", "ar-AE"]
    }

    // MARK: - Animation Durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
        static let postRecitationDisplay: Double = 5.0
    }

    // MARK: - UI Sizing
    enum Sizing {
        static let cornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 20
        static let buttonHeight: CGFloat = 56
        static let iconSize: CGFloat = 60
        static let smallIconSize: CGFloat = 40
        static let cardPadding: CGFloat = 16
    }
}

// MARK: - Color Palette
struct WiqayahColors {
    static let primary = Color(hex: "#1B4332")      // Deep green
    static let secondary = Color(hex: "#2D6A4F")    // Medium green
    static let accent = Color(hex: "#52B788")       // Light green
    static let background = Color(hex: "#F8F9FA")   // Off-white
    static let cardBackground = Color.white
    static let text = Color(hex: "#212529")         // Near black
    static let textSecondary = Color(hex: "#6C757D")
    static let error = Color(hex: "#D62828")        // Red
    static let success = Color(hex: "#52B788")      // Green
    static let warning = Color(hex: "#F4A261")      // Orange

    // Gradient
    static let primaryGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography
struct WiqayahFonts {
    // Headers
    static func header(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }

    // Body text
    static func body(_ size: CGFloat = 17) -> Font {
        .system(size: size, weight: .regular)
    }

    // Arabic text
    static func arabic(_ size: CGFloat = 24) -> Font {
        .custom("NotoNaskhArabic-Regular", size: size)
    }

    // Arabic bold
    static func arabicBold(_ size: CGFloat = 24) -> Font {
        .custom("NotoNaskhArabic-Bold", size: size)
    }

    // Captions
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular)
    }

    // Button text
    static func button() -> Font {
        .system(size: 17, weight: .semibold)
    }
}

// MARK: - App Info
enum AppInfo {
    static let appName = "Wiqayah"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    static let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    static let supportEmail = "support@wiqayah.app"
    static let privacyPolicyURL = URL(string: "https://wiqayah.app/privacy")!
    static let termsOfServiceURL = URL(string: "https://wiqayah.app/terms")!
}
