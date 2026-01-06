import SwiftUI

/// App selection screen - third step of onboarding
struct SelectAppsView: View {
    @Binding var selectedApps: Set<String>
    var onContinue: () -> Void

    private let apps = BlockedApp.supportedApps

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Select Apps to Block")
                    .font(WiqayahFonts.header())
                    .foregroundColor(WiqayahColors.text)

                Text("Choose which apps you want to guard against. You can change this later.")
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.top, 40)
            .padding(.bottom, 32)

            // App grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(apps) { app in
                        AppSelectionItem(
                            app: app,
                            isSelected: selectedApps.contains(app.id),
                            onTap: {
                                toggleApp(app.id)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            // Selection count
            if !selectedApps.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(WiqayahColors.primary)

                    Text("\(selectedApps.count) app\(selectedApps.count == 1 ? "" : "s") selected")
                        .font(WiqayahFonts.body())
                        .foregroundColor(WiqayahColors.text)
                }
                .padding(.vertical, 12)
            }

            // Continue button
            Button(action: onContinue) {
                Text(selectedApps.isEmpty ? "Skip for Now" : "Continue")
                    .primaryButtonStyle()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private func toggleApp(_ appId: String) {
        HapticManager.shared.selectionChanged()

        if selectedApps.contains(appId) {
            selectedApps.remove(appId)
        } else {
            selectedApps.insert(appId)
        }
    }
}

// MARK: - App Selection Item
struct AppSelectionItem: View {
    let app: BlockedApp
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                ZStack {
                    AppIconView(app: app, size: 70)

                    if isSelected {
                        Circle()
                            .fill(WiqayahColors.primary)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 25, y: -25)
                    }
                }

                Text(app.name)
                    .font(WiqayahFonts.body(14))
                    .foregroundColor(WiqayahColors.text)
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                    .fill(isSelected ? WiqayahColors.primary.opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Constants.Sizing.cornerRadius)
                    .stroke(isSelected ? WiqayahColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Select All Button
struct SelectAllButton: View {
    @Binding var selectedApps: Set<String>
    let allApps: [BlockedApp]

    private var allSelected: Bool {
        selectedApps.count == allApps.count
    }

    var body: some View {
        Button(action: toggleAll) {
            HStack {
                Image(systemName: allSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(WiqayahColors.primary)

                Text(allSelected ? "Deselect All" : "Select All")
                    .font(WiqayahFonts.body())
                    .foregroundColor(WiqayahColors.primary)
            }
        }
    }

    private func toggleAll() {
        HapticManager.shared.lightImpact()

        if allSelected {
            selectedApps.removeAll()
        } else {
            selectedApps = Set(allApps.map { $0.id })
        }
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var selectedApps: Set<String> = []

        var body: some View {
            SelectAppsView(selectedApps: $selectedApps, onContinue: {})
                .background(WiqayahColors.background)
        }
    }

    return PreviewWrapper()
}
