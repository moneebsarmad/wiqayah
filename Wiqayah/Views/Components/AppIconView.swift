import SwiftUI

/// Displays a social media app icon with optional overlay
struct AppIconView: View {
    let app: BlockedApp
    var size: CGFloat = Constants.Sizing.iconSize
    var showBlockedOverlay: Bool = false
    var isSelected: Bool = false

    var body: some View {
        ZStack {
            // App icon
            appIcon
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: size * 0.22))

            // Blocked overlay
            if showBlockedOverlay {
                blockedOverlay
            }

            // Selection indicator
            if isSelected {
                selectionIndicator
            }
        }
        .frame(width: size, height: size)
    }

    // MARK: - App Icon
    private var appIcon: some View {
        ZStack {
            // Background gradient based on app
            LinearGradient(
                colors: gradientColors(for: app.iconName),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // App icon/symbol
            Image(systemName: systemIconName(for: app.iconName))
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Blocked Overlay
    private var blockedOverlay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .fill(Color.black.opacity(0.5))

            Image(systemName: "lock.fill")
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Selection Indicator
    private var selectionIndicator: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.22)
                .stroke(WiqayahColors.primary, lineWidth: 3)

            Circle()
                .fill(WiqayahColors.primary)
                .frame(width: size * 0.3, height: size * 0.3)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: size * 0.15, weight: .bold))
                        .foregroundColor(.white)
                )
                .offset(x: size * 0.35, y: -size * 0.35)
        }
    }

    // MARK: - Helpers

    private func gradientColors(for iconName: String) -> [Color] {
        switch iconName.lowercased() {
        case "tiktok":
            return [Color(hex: "#010101"), Color(hex: "#69C9D0")]
        case "instagram":
            return [Color(hex: "#833AB4"), Color(hex: "#FD1D1D"), Color(hex: "#F77737")]
        case "youtube":
            return [Color(hex: "#FF0000"), Color(hex: "#CC0000")]
        case "facebook":
            return [Color(hex: "#1877F2"), Color(hex: "#1565D8")]
        case "snapchat":
            return [Color(hex: "#FFFC00"), Color(hex: "#FFE600")]
        case "twitter":
            return [Color(hex: "#1DA1F2"), Color(hex: "#0D8BD9")]
        case "reddit":
            return [Color(hex: "#FF4500"), Color(hex: "#FF5700")]
        case "linkedin":
            return [Color(hex: "#0077B5"), Color(hex: "#005885")]
        default:
            return [WiqayahColors.primary, WiqayahColors.secondary]
        }
    }

    private func systemIconName(for iconName: String) -> String {
        switch iconName.lowercased() {
        case "tiktok":
            return "music.note"
        case "instagram":
            return "camera.fill"
        case "youtube":
            return "play.rectangle.fill"
        case "facebook":
            return "person.2.fill"
        case "snapchat":
            return "message.fill"
        case "twitter":
            return "at"
        case "reddit":
            return "bubble.left.and.bubble.right.fill"
        case "linkedin":
            return "briefcase.fill"
        default:
            return "app.fill"
        }
    }
}

// MARK: - App Icon Row
struct AppIconRow: View {
    let app: BlockedApp
    var isSelected: Bool = false
    var showUsage: Bool = false
    var usageMinutes: Int = 0

    var body: some View {
        HStack(spacing: 16) {
            AppIconView(app: app, size: 50, isSelected: isSelected)

            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.text)

                if showUsage {
                    Text("\(usageMinutes) min today")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.textSecondary)
                } else if app.isBlocked {
                    Text("Blocked")
                        .font(WiqayahFonts.caption())
                        .foregroundColor(WiqayahColors.primary)
                }
            }

            Spacer()

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(WiqayahColors.primary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - App Grid Item
struct AppGridItem: View {
    let app: BlockedApp
    var isSelected: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                AppIconView(app: app, size: 60, isSelected: isSelected)

                Text(app.name)
                    .font(WiqayahFonts.caption())
                    .foregroundColor(WiqayahColors.text)
                    .lineLimit(1)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        // Single icons
        HStack(spacing: 20) {
            ForEach(BlockedApp.supportedApps.prefix(4)) { app in
                AppIconView(app: app)
            }
        }

        // With blocked overlay
        HStack(spacing: 20) {
            ForEach(BlockedApp.supportedApps.prefix(4)) { app in
                AppIconView(app: app, showBlockedOverlay: true)
            }
        }

        // Row style
        VStack {
            AppIconRow(app: BlockedApp.supportedApps[0], isSelected: true)
            AppIconRow(app: BlockedApp.supportedApps[1], showUsage: true, usageMinutes: 15)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    .padding()
    .background(WiqayahColors.background)
}
