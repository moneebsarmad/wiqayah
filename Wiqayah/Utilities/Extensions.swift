import SwiftUI

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Date Extensions
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }

    var dayOfWeekShort: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    func adding(minutes: Int) -> Date {
        Calendar.current.date(byAdding: .minute, value: minutes, to: self) ?? self
    }

    func adding(hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    func adding(days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
}

// MARK: - String Extensions
extension String {
    /// Normalize Arabic text for comparison
    var normalizedArabic: String {
        // Remove diacritics and normalize
        let stripped = self
            .folding(options: .diacriticInsensitive, locale: Locale(identifier: "ar"))
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove common Arabic diacritics
        let diacritics = CharacterSet(charactersIn: "\u{064B}\u{064C}\u{064D}\u{064E}\u{064F}\u{0650}\u{0651}\u{0652}")
        return stripped.unicodeScalars.filter { !diacritics.contains($0) }.map { String($0) }.joined()
    }

    /// Calculate Levenshtein similarity (0.0 - 1.0)
    func levenshteinSimilarity(to other: String) -> Double {
        let s1 = Array(self)
        let s2 = Array(other)
        let m = s1.count
        let n = s2.count

        if m == 0 { return n == 0 ? 1.0 : 0.0 }
        if n == 0 { return 0.0 }

        var matrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m { matrix[i][0] = i }
        for j in 0...n { matrix[0][j] = j }

        for i in 1...m {
            for j in 1...n {
                let cost = s1[i-1] == s2[j-1] ? 0 : 1
                matrix[i][j] = Swift.min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }

        let distance = Double(matrix[m][n])
        let maxLength = Double(Swift.max(m, n))
        return 1.0 - (distance / maxLength)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .padding(Constants.Sizing.cardPadding)
            .background(WiqayahColors.cardBackground)
            .cornerRadius(Constants.Sizing.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(WiqayahFonts.button())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Sizing.buttonHeight)
            .background(WiqayahColors.primary)
            .cornerRadius(Constants.Sizing.cornerRadius)
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(WiqayahFonts.button())
            .foregroundColor(WiqayahColors.primary)
            .frame(maxWidth: .infinity)
            .frame(height: Constants.Sizing.buttonHeight)
            .background(WiqayahColors.primary.opacity(0.1))
            .cornerRadius(Constants.Sizing.cornerRadius)
    }

    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Int Extensions
extension Int {
    var minutesToHoursMinutes: String {
        let hours = self / 60
        let minutes = self % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - Bundle Extensions
extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T? {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            print("Failed to locate \(file) in bundle.")
            return nil
        }

        guard let data = try? Data(contentsOf: url) else {
            print("Failed to load \(file) from bundle.")
            return nil
        }

        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            print("Failed to decode \(file) from bundle.")
            return nil
        }

        return loaded
    }
}
