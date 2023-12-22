//
//  SettingsView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//
 
import SwiftUI
import AuthenticationServices
import JWTDecode

struct SettingsView: View {
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @State private var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    @State private var isUserLoggedIn: Bool = UserDefaults.standard.string(forKey: "userIdentifier") != nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if isUserLoggedIn {
                    // Display user information and log-off button
                    Text("User Name: \(userName)")
                    Text("User Email: \(userEmail)")
                    Button("Log Off", action: handleLogOff)
                        .padding()
                } else {
                    // Display Sign in with Apple Button
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                switch authResults.credential {
                                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                    // Successfully authenticated
                                    handleAuthorizationAppleIDCredential(appleIDCredential)
                                default:
                                    break
                                }
                            case .failure(let error):
                                // Authentication failed
                                print("Authentication failed: \(error.localizedDescription)")
                            }
                        }
                    )
                    .frame(height: 44)
                    .padding()
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 735)
    }

    private func handleAuthorizationAppleIDCredential(_ appleIDCredential: ASAuthorizationAppleIDCredential) {
        DispatchQueue.main.async {
            if let fullName = appleIDCredential.fullName {
                self.userName = [fullName.givenName, fullName.familyName].compactMap { $0 }.joined(separator: " ")
                UserDefaults.standard.set(self.userName, forKey: "userName")
            }
            if let email = appleIDCredential.email {
                self.userEmail = email
                UserDefaults.standard.set(self.userEmail, forKey: "userEmail")
            }
            let userIdentifier = appleIDCredential.user
            UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
            self.isUserLoggedIn = true
        }
    }

    private func handleLogOff() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        userName = ""
        userEmail = ""
        isUserLoggedIn = false
    }
    
    func decodeIdentityToken(_ token: String) {
        do {
            let jwt = try decode(jwt: token)
            // Handle decoded JWT as needed
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
}
