import SwiftUI

/// A customizable circular or linear progress bar
struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    var style: Style = .linear
    var showLabel: Bool = true
    var labelText: String?
    var color: Color = WiqayahColors.primary
    var backgroundColor: Color = WiqayahColors.primary.opacity(0.2)
    var lineWidth: CGFloat = 8

    enum Style {
        case linear
        case circular
    }

    var body: some View {
        switch style {
        case .linear:
            linearProgress
        case .circular:
            circularProgress
        }
    }

    // MARK: - Linear Progress
    private var linearProgress: some View {
        VStack(alignment: .leading, spacing: 8) {
            if showLabel {
                HStack {
                    if let text = labelText {
                        Text(text)
                            .font(WiqayahFonts.caption())
                            .foregroundColor(WiqayahColors.textSecondary)
                    }
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: lineWidth / 2)
                        .fill(backgroundColor)
                        .frame(height: lineWidth)

                    // Progress
                    RoundedRectangle(cornerRadius: lineWidth / 2)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * CGFloat(min(1, max(0, progress))), height: lineWidth)
                        .animation(.easeInOut(duration: Constants.Animation.standard), value: progress)
                }
            }
            .frame(height: lineWidth)
        }
    }

    // MARK: - Circular Progress
    private var circularProgress: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(backgroundColor, lineWidth: lineWidth)

            // Progress arc
            Circle()
                .trim(from: 0, to: CGFloat(min(1, max(0, progress))))
                .stroke(
                    progressColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: Constants.Animation.standard), value: progress)

            // Center label
            if showLabel {
                VStack(spacing: 2) {
                    Text("\(Int(progress * 100))")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(WiqayahColors.text)
                    Text("%")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Dynamic Color
    private var progressColor: Color {
        if progress >= 0.9 {
            return WiqayahColors.error
        } else if progress >= 0.7 {
            return WiqayahColors.warning
        } else {
            return color
        }
    }
}

// MARK: - Usage Progress Bar
struct UsageProgressBar: View {
    let minutesUsed: Int
    let limit: Int
    var showDetails: Bool = true

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return Double(minutesUsed) / Double(limit)
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressBar(
                progress: progress,
                style: .linear,
                showLabel: false,
                lineWidth: 12
            )

            if showDetails {
                HStack {
                    Text("\(minutesUsed) min used")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)

                    Spacer()

                    Text("\(max(0, limit - minutesUsed)) min left")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(remainingColor)
                }
            }
        }
    }

    private var remainingColor: Color {
        let remaining = limit - minutesUsed
        if remaining <= 5 {
            return WiqayahColors.error
        } else if remaining <= 15 {
            return WiqayahColors.warning
        } else {
            return WiqayahColors.textSecondary
        }
    }
}

// MARK: - Circular Usage View
struct CircularUsageView: View {
    let minutesUsed: Int
    let limit: Int

    private var progress: Double {
        guard limit > 0 else { return 0 }
        return Double(minutesUsed) / Double(limit)
    }

    var body: some View {
        ZStack {
            ProgressBar(
                progress: progress,
                style: .circular,
                showLabel: false,
                lineWidth: 12
            )
            .frame(width: 120, height: 120)

            VStack(spacing: 4) {
                Text("\(minutesUsed)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(WiqayahColors.text)
                Text("of \(limit) min")
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.textSecondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 40) {
        ProgressBar(progress: 0.3, style: .linear)
            .padding()

        ProgressBar(progress: 0.7, style: .linear, labelText: "Daily Usage")
            .padding()

        ProgressBar(progress: 0.5, style: .circular)
            .frame(width: 100, height: 100)

        UsageProgressBar(minutesUsed: 35, limit: 60)
            .padding()

        CircularUsageView(minutesUsed: 45, limit: 60)
    }
    .padding()
}
