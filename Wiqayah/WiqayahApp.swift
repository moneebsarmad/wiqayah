import SwiftUI
import UIKit

/// Main entry point for the Wiqayah app
@main
struct WiqayahApp: App {
    // MARK: - State Objects
    @StateObject private var dataManager = CoreDataManager.shared
    @StateObject private var blockerService = AppBlockerService.shared
    @StateObject private var authManager = AuthManager.shared

    // MARK: - App State
    @State private var showOnboarding = false

    // MARK: - App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataManager)
                .environmentObject(blockerService)
                .environmentObject(authManager)
                .onAppear {
                    setupApp()
                }
                .fullScreenCover(isPresented: $showOnboarding) {
                    OnboardingContainerView()
                }
        }
    }

    // MARK: - Setup
    private func setupApp() {
        // Check if onboarding needed
        if !dataManager.hasCompletedOnboarding {
            showOnboarding = true
        }

        // Setup notification categories
        NotificationService.shared.setupNotificationCategories()

        // Check for daily reset
        dataManager.checkAndResetDaily()

        // Enable blocking if apps are selected
        if !dataManager.getBlockedApps().isEmpty {
            blockerService.enableBlocking()
        }

        // Configure appearance
        configureAppearance()
    }

    private func configureAppearance() {
        // Navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(WiqayahColors.background)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(WiqayahColors.text)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(WiqayahColors.text)]

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        // Tab bar appearance
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = UIColor(WiqayahColors.background)

        UITabBar.appearance().standardAppearance = tabAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabAppearance
    }
}

// MARK: - Content View (Root View)
struct ContentView: View {
    @EnvironmentObject var dataManager: CoreDataManager
    @EnvironmentObject var blockerService: AppBlockerService

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(WiqayahColors.primary)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Request notification authorization on launch
        Task {
            await NotificationService.shared.requestAuthorization()
        }

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Check for daily reset when app becomes active
        CoreDataManager.shared.checkAndResetDaily()

        // Update prayer times
        PrayerTimeService.shared.fajrTime = PrayerTimeService.shared.calculateFajrTime()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Save any pending data
        // End active sessions if needed
        if AppBlockerService.shared.activeSession != nil {
            AppBlockerService.shared.endCurrentSession()
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(CoreDataManager.shared)
        .environmentObject(AppBlockerService.shared)
        .environmentObject(AuthManager.shared)
}
