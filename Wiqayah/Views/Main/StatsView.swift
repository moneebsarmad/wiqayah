import SwiftUI
import Charts

/// Statistics and analytics view
struct StatsView: View {
    @StateObject private var dataManager = CoreDataManager.shared
    @StateObject private var usageService = UsageTrackingService.shared

    @State private var selectedTimeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Time range picker
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)

                // Weekly usage chart
                weeklyUsageChart
                    .padding(.horizontal, 20)

                // Summary cards
                summaryCards
                    .padding(.horizontal, 20)

                // App breakdown
                appBreakdownSection
                    .padding(.horizontal, 20)

                // Dhikr stats
                dhikrStatsSection
                    .padding(.horizontal, 20)

                // Streak section
                streakSection
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
        }
        .background(WiqayahColors.background)
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Weekly Usage Chart
    private var weeklyUsageChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Usage")
                .font(WiqayahFonts.body())
                .fontWeight(.semibold)
                .foregroundColor(WiqayahColors.text)

            let weeklyStats = usageService.getWeeklyStats()

            Chart(weeklyStats) { stat in
                BarMark(
                    x: .value("Day", stat.dayOfWeek),
                    y: .value("Minutes", stat.totalMinutesUsed)
                )
                .foregroundStyle(
                    stat.date.isToday
                        ? WiqayahColors.primary
                        : WiqayahColors.primary.opacity(0.5)
                )
                .cornerRadius(4)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisValueLabel()
                }
            }

            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(WiqayahColors.primary)
                        .frame(width: 8, height: 8)
                    Text("Today")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }

                Text("Avg: \(usageService.getAverageDailyMinutes()) min/day")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }
        }
        .cardStyle()
    }

    // MARK: - Summary Cards
    private var summaryCards: some View {
        HStack(spacing: 12) {
            SummaryCard(
                title: "This Week",
                value: "\(usageService.getWeeklyTotalMinutes())",
                unit: "min",
                icon: "clock.fill",
                color: WiqayahColors.primary
            )

            SummaryCard(
                title: "Daily Avg",
                value: "\(usageService.getAverageDailyMinutes())",
                unit: "min",
                icon: "chart.bar.fill",
                color: WiqayahColors.secondary
            )

            SummaryCard(
                title: "Streak",
                value: "\(usageService.getCurrentStreak())",
                unit: "days",
                icon: "flame.fill",
                color: WiqayahColors.warning
            )
        }
    }

    // MARK: - App Breakdown Section
    private var appBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Usage by App")
                .font(WiqayahFonts.body())
                .fontWeight(.semibold)
                .foregroundColor(WiqayahColors.text)

            let breakdown = usageService.getTodayUsageByApp()
            let sortedApps = breakdown.sorted { $0.value > $1.value }

            if sortedApps.isEmpty {
                Text("No usage data yet")
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ForEach(sortedApps, id: \.key) { appId, minutes in
                    if let app = dataManager.blockedApps.first(where: { $0.id == appId }) {
                        AppUsageRow(app: app, minutes: minutes, totalMinutes: usageService.todayTotalMinutes)
                    }
                }
            }
        }
        .cardStyle()
    }

    // MARK: - Dhikr Stats Section
    private var dhikrStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Dhikr Performance")
                .font(WiqayahFonts.body())
                .fontWeight(.semibold)
                .foregroundColor(WiqayahColors.text)

            let todayStats = dataManager.getTodayStats()

            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(todayStats.dhikrCompleted)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(WiqayahColors.primary)

                    Text("Completed Today")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }

                Divider()
                    .frame(height: 60)

                VStack(spacing: 8) {
                    Text("\(Int(todayStats.dhikrCompletionRate * 100))%")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(WiqayahColors.success)

                    Text("Success Rate")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }

                Divider()
                    .frame(height: 60)

                VStack(spacing: 8) {
                    Text("\(todayStats.bypassesUsed)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(WiqayahColors.warning)

                    Text("Bypasses Used")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .cardStyle()
    }

    // MARK: - Streak Section
    private var streakSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .font(.system(size: 32))
                    .foregroundColor(WiqayahColors.warning)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(usageService.getCurrentStreak()) Day Streak")
                        .font(WiqayahFonts.header(20))
                        .foregroundColor(WiqayahColors.text)

                    Text(MotivationalMessages.streakMessage(days: usageService.getCurrentStreak()))
                        .font(WiqayahFonts.body())
                        .foregroundColor(WiqayahColors.textSecondary)
                }

                Spacer()
            }
        }
        .cardStyle()
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            VStack(spacing: 2) {
                HStack(alignment: .bottom, spacing: 2) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(WiqayahColors.text)

                    Text(unit)
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }

                Text(title)
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(Constants.Sizing.cornerRadius)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - App Usage Row
struct AppUsageRow: View {
    let app: BlockedApp
    let minutes: Int
    let totalMinutes: Int

    private var percentage: Double {
        guard totalMinutes > 0 else { return 0 }
        return Double(minutes) / Double(totalMinutes)
    }

    var body: some View {
        HStack(spacing: 12) {
            AppIconView(app: app, size: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(WiqayahFonts.body(14))
                    .foregroundColor(WiqayahColors.text)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(WiqayahColors.primary.opacity(0.2))
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(WiqayahColors.primary)
                            .frame(width: geometry.size.width * CGFloat(percentage), height: 4)
                    }
                }
                .frame(height: 4)
            }

            Text("\(minutes) min")
                .font(WiqayahFonts.body(14))
                .fontWeight(.semibold)
                .foregroundColor(WiqayahColors.text)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        StatsView()
    }
}
