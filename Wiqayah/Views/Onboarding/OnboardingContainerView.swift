import SwiftUI

/// Container view that manages the onboarding flow
struct OnboardingContainerView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            WiqayahColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicator
                progressIndicator
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                // Current step content
                TabView(selection: $viewModel.currentStep) {
                    WelcomeView(onContinue: viewModel.nextStep)
                        .tag(OnboardingStep.welcome)

                    HowItWorksView(onContinue: viewModel.nextStep)
                        .tag(OnboardingStep.howItWorks)

                    SelectAppsView(
                        selectedApps: $viewModel.selectedApps,
                        onContinue: viewModel.nextStep
                    )
                    .tag(OnboardingStep.selectApps)

                    SetLimitView(
                        dailyLimit: $viewModel.dailyLimit,
                        onContinue: viewModel.nextStep
                    )
                    .tag(OnboardingStep.setLimit)

                    PermissionsView(onComplete: viewModel.completeOnboarding)
                        .tag(OnboardingStep.permissions)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: viewModel.currentStep)
            }
        }
        .onChange(of: viewModel.isOnboardingComplete) { _, isComplete in
            if isComplete {
                dismiss()
            }
        }
    }

    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue
                          ? WiqayahColors.primary
                          : WiqayahColors.primary.opacity(0.2))
                    .frame(height: 4)
            }
        }
    }
}

// MARK: - Onboarding Steps
enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case howItWorks = 1
    case selectApps = 2
    case setLimit = 3
    case permissions = 4

    var title: String {
        switch self {
        case .welcome: return "Welcome"
        case .howItWorks: return "How It Works"
        case .selectApps: return "Select Apps"
        case .setLimit: return "Set Limit"
        case .permissions: return "Permissions"
        }
    }
}

// MARK: - Onboarding View Model
@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var selectedApps: Set<String> = []
    @Published var dailyLimit: Int = 60
    @Published var isOnboardingComplete = false

    private let dataManager = CoreDataManager.shared

    func nextStep() {
        HapticManager.shared.lightImpact()

        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex < OnboardingStep.allCases.count - 1 else {
            return
        }

        withAnimation {
            currentStep = OnboardingStep.allCases[currentIndex + 1]
        }
    }

    func previousStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep),
              currentIndex > 0 else {
            return
        }

        withAnimation {
            currentStep = OnboardingStep.allCases[currentIndex - 1]
        }
    }

    func completeOnboarding() {
        // Save selected apps
        for appId in selectedApps {
            dataManager.setAppBlocked(bundleId: appId, blocked: true)
        }

        // Save daily limit
        dataManager.setDailyLimit(dailyLimit)

        // Mark onboarding complete
        dataManager.hasCompletedOnboarding = true

        HapticManager.shared.success()

        isOnboardingComplete = true
    }
}

// MARK: - Preview
#Preview {
    OnboardingContainerView()
}
