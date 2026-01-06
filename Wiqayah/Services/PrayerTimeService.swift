import Foundation
import CoreLocation

/// Calculates Islamic prayer times for daily reset scheduling
final class PrayerTimeService: ObservableObject {
    static let shared = PrayerTimeService()

    // MARK: - Published Properties
    @Published var fajrTime: Date?
    @Published var nextResetTime: Date?
    @Published var currentLocation: CLLocation?

    // MARK: - Calculation Method
    enum CalculationMethod: String, CaseIterable {
        case muslimWorldLeague = "Muslim World League"
        case isna = "ISNA (North America)"
        case egypt = "Egyptian General Authority"
        case makkah = "Umm al-Qura (Makkah)"
        case karachi = "University of Islamic Sciences, Karachi"

        var fajrAngle: Double {
            switch self {
            case .muslimWorldLeague: return 18.0
            case .isna: return 15.0
            case .egypt: return 19.5
            case .makkah: return 18.5
            case .karachi: return 18.0
            }
        }

        var ishaAngle: Double {
            switch self {
            case .muslimWorldLeague: return 17.0
            case .isna: return 15.0
            case .egypt: return 17.5
            case .makkah: return 0 // 90 minutes after Maghrib
            case .karachi: return 18.0
            }
        }
    }

    @Published var calculationMethod: CalculationMethod = .muslimWorldLeague

    private init() {}

    // MARK: - Main Calculation

    /// Calculate Fajr time for a given location and date
    func calculateFajrTime(latitude: Double, longitude: Double, date: Date = Date()) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)

        guard let year = components.year,
              let month = components.month,
              let day = components.day else {
            return nil
        }

        // Calculate Julian date
        let julianDate = calculateJulianDate(year: year, month: month, day: day)

        // Calculate sun position
        let sunDeclination = calculateSunDeclination(julianDate: julianDate)
        let equationOfTime = calculateEquationOfTime(julianDate: julianDate)

        // Calculate Fajr time
        let fajrAngle = calculationMethod.fajrAngle
        let fajrTime = calculatePrayerTime(
            latitude: latitude,
            angle: fajrAngle,
            sunDeclination: sunDeclination,
            equationOfTime: equationOfTime,
            isSunrise: false
        )

        // Convert to Date
        let timezone = TimeZone.current
        let utcOffset = Double(timezone.secondsFromGMT(for: date)) / 3600.0
        let longitudeCorrection = longitude / 15.0

        let adjustedTime = fajrTime - longitudeCorrection + utcOffset

        var dateComponents = components
        let hours = Int(adjustedTime)
        let minutes = Int((adjustedTime - Double(hours)) * 60)

        dateComponents.hour = hours
        dateComponents.minute = minutes
        dateComponents.second = 0

        return calendar.date(from: dateComponents)
    }

    /// Calculate Fajr time using current location
    func calculateFajrTime(for date: Date = Date()) -> Date? {
        guard let location = currentLocation else {
            // Use default location (Makkah) if no location available
            return calculateFajrTime(latitude: 21.4225, longitude: 39.8262, date: date)
        }

        return calculateFajrTime(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            date: date
        )
    }

    /// Get the next reset time (next Fajr)
    func getNextResetTime() -> Date {
        let now = Date()

        // Try today's Fajr
        if let todayFajr = calculateFajrTime(for: now), todayFajr > now {
            nextResetTime = todayFajr
            return todayFajr
        }

        // Otherwise, tomorrow's Fajr
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: now)!
        let tomorrowFajr = calculateFajrTime(for: tomorrow) ?? now.adding(days: 1)
        nextResetTime = tomorrowFajr
        return tomorrowFajr
    }

    /// Format Fajr time for display
    func getFormattedFajrTime() -> String {
        guard let fajr = fajrTime ?? calculateFajrTime() else {
            return "N/A"
        }

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: fajr)
    }

    /// Get time until next reset
    func getTimeUntilReset() -> String {
        let resetTime = getNextResetTime()
        let interval = resetTime.timeIntervalSince(Date())

        if interval <= 0 {
            return "Resetting..."
        }

        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes) min"
        }
    }

    // MARK: - Location

    func updateLocation(_ location: CLLocation) {
        currentLocation = location
        fajrTime = calculateFajrTime()
        nextResetTime = getNextResetTime()
    }

    // MARK: - Astronomical Calculations

    private func calculateJulianDate(year: Int, month: Int, day: Int) -> Double {
        var y = year
        var m = month

        if m <= 2 {
            y -= 1
            m += 12
        }

        let a = Int(Double(y) / 100.0)
        let b = 2 - a + Int(Double(a) / 4.0)

        return Double(Int(365.25 * Double(y + 4716))) +
               Double(Int(30.6001 * Double(m + 1))) +
               Double(day) + Double(b) - 1524.5
    }

    private func calculateSunDeclination(julianDate: Double) -> Double {
        let d = julianDate - 2451545.0
        let g = (357.529 + 0.98560028 * d).truncatingRemainder(dividingBy: 360.0)
        let q = (280.459 + 0.98564736 * d).truncatingRemainder(dividingBy: 360.0)
        let l = (q + 1.915 * sin(g.toRadians()) + 0.020 * sin(2 * g.toRadians()))
            .truncatingRemainder(dividingBy: 360.0)
        let e = 23.439 - 0.00000036 * d
        let ra = atan2(cos(e.toRadians()) * sin(l.toRadians()), cos(l.toRadians())).toDegrees()
        let d_sun = asin(sin(e.toRadians()) * sin(l.toRadians())).toDegrees()
        return d_sun
    }

    private func calculateEquationOfTime(julianDate: Double) -> Double {
        let d = julianDate - 2451545.0
        let g = (357.529 + 0.98560028 * d).truncatingRemainder(dividingBy: 360.0)
        let q = (280.459 + 0.98564736 * d).truncatingRemainder(dividingBy: 360.0)
        let l = (q + 1.915 * sin(g.toRadians()) + 0.020 * sin(2 * g.toRadians()))
            .truncatingRemainder(dividingBy: 360.0)
        let e = 23.439 - 0.00000036 * d
        var ra = atan2(cos(e.toRadians()) * sin(l.toRadians()), cos(l.toRadians())).toDegrees()
        ra = ra / 15.0

        let eqt = q / 15.0 - ra
        return eqt
    }

    private func calculatePrayerTime(
        latitude: Double,
        angle: Double,
        sunDeclination: Double,
        equationOfTime: Double,
        isSunrise: Bool
    ) -> Double {
        let latRad = latitude.toRadians()
        let decRad = sunDeclination.toRadians()
        let angleRad = angle.toRadians()

        var cosHA = (sin(-angleRad) - sin(latRad) * sin(decRad)) / (cos(latRad) * cos(decRad))
        cosHA = min(1, max(-1, cosHA)) // Clamp to valid range

        var hourAngle = acos(cosHA).toDegrees() / 15.0

        if isSunrise {
            hourAngle = -hourAngle
        }

        let time = 12.0 - hourAngle - equationOfTime
        return time
    }
}

// MARK: - Angle Conversions
private extension Double {
    func toRadians() -> Double {
        self * .pi / 180.0
    }

    func toDegrees() -> Double {
        self * 180.0 / .pi
    }
}
