import Foundation
import AuthenticationServices
import SwiftUI

/// Manages authentication using Sign in with Apple
final class AuthManager: NSObject, ObservableObject {
    static let shared = AuthManager()

    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var userIdentifier: String?
    @Published var userName: String?
    @Published var userEmail: String?
    @Published var authError: AuthError?

    // MARK: - Keychain Keys
    private enum KeychainKeys {
        static let userIdentifier = "wiqayah_user_identifier"
        static let userName = "wiqayah_user_name"
        static let userEmail = "wiqayah_user_email"
    }

    // MARK: - Error Types
    enum AuthError: LocalizedError, Equatable {
        case signInFailed
        case credentialRevoked
        case unknown(String)

        var errorDescription: String? {
            switch self {
            case .signInFailed:
                return "Sign in failed. Please try again."
            case .credentialRevoked:
                return "Your credentials have been revoked. Please sign in again."
            case .unknown(let message):
                return message
            }
        }

        static func == (lhs: AuthError, rhs: AuthError) -> Bool {
            switch (lhs, rhs) {
            case (.signInFailed, .signInFailed):
                return true
            case (.credentialRevoked, .credentialRevoked):
                return true
            case (.unknown(let a), .unknown(let b)):
                return a == b
            default:
                return false
            }
        }
    }

    // MARK: - Initialization
    override private init() {
        super.init()
        checkExistingCredentials()
    }

    // MARK: - Public Methods

    /// Initiates Sign in with Apple flow
    func signInWithApple() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
    }

    /// Signs out the current user
    func signOut() {
        // Clear stored credentials
        deleteFromKeychain(key: KeychainKeys.userIdentifier)
        deleteFromKeychain(key: KeychainKeys.userName)
        deleteFromKeychain(key: KeychainKeys.userEmail)

        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.userIdentifier = nil
            self.userName = nil
            self.userEmail = nil
        }
    }

    /// Checks if user is still authenticated
    func checkCredentialState() {
        guard let userIdentifier = userIdentifier else {
            isAuthenticated = false
            return
        }

        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userIdentifier) { [weak self] state, _ in
            DispatchQueue.main.async {
                switch state {
                case .authorized:
                    self?.isAuthenticated = true
                case .revoked, .notFound:
                    self?.signOut()
                    self?.authError = .credentialRevoked
                case .transferred:
                    self?.signOut()
                @unknown default:
                    break
                }
            }
        }
    }

    // MARK: - Private Methods

    private func checkExistingCredentials() {
        if let identifier = loadFromKeychain(key: KeychainKeys.userIdentifier) {
            userIdentifier = identifier
            userName = loadFromKeychain(key: KeychainKeys.userName)
            userEmail = loadFromKeychain(key: KeychainKeys.userEmail)
            checkCredentialState()
        }
    }

    private func handleSuccessfulAuth(credential: ASAuthorizationAppleIDCredential) {
        let identifier = credential.user

        // Save to keychain
        saveToKeychain(key: KeychainKeys.userIdentifier, value: identifier)

        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !name.isEmpty {
                saveToKeychain(key: KeychainKeys.userName, value: name)
                userName = name
            }
        }

        if let email = credential.email {
            saveToKeychain(key: KeychainKeys.userEmail, value: email)
            userEmail = email
        }

        DispatchQueue.main.async {
            self.userIdentifier = identifier
            self.isAuthenticated = true
            self.authError = nil
        }
    }

    // MARK: - Keychain Helpers

    private func saveToKeychain(key: String, value: String) {
        let data = Data(value.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete existing item
        SecItemDelete(query as CFDictionary)

        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadFromKeychain(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func deleteFromKeychain(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]

        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {
            handleSuccessfulAuth(credential: credential)
        }
    }

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.authError = .unknown(error.localizedDescription)
        }
    }
}

// MARK: - SwiftUI Sign In Button
struct SignInWithAppleButton: View {
    @ObservedObject private var authManager = AuthManager.shared
    var onSuccess: (() -> Void)?
    var onError: ((AuthManager.AuthError) -> Void)?

    var body: some View {
        SignInWithAppleButtonViewRepresentable()
            .frame(height: Constants.Sizing.buttonHeight)
            .onTapGesture {
                authManager.signInWithApple()
            }
            .onChange(of: authManager.isAuthenticated) { _, isAuthenticated in
                if isAuthenticated {
                    onSuccess?()
                }
            }
            .onChange(of: authManager.authError) { _, error in
                if let error = error {
                    onError?(error)
                }
            }
    }
}

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    }

    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {}
}
