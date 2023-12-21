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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
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

                // Display user information
                if !userName.isEmpty {
                    Text("User Name: \(userName)")
                }
                if !userEmail.isEmpty {
                    Text("User Email: \(userEmail)")
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
                UserDefaults.standard.set(self.userName, forKey: "userName") // Save the user's name persistently
                print("User Name: \(self.userName)")
            }
            if let email = appleIDCredential.email {
                self.userEmail = email
                UserDefaults.standard.set(self.userEmail, forKey: "userEmail") // Save the user's email persistently
                print("User Email: \(self.userEmail)")
            }

            // Also save and log the user's unique identifier for subsequent logins
            let userIdentifier = appleIDCredential.user
            UserDefaults.standard.set(userIdentifier, forKey: "userIdentifier")
            print("User Identifier: \(userIdentifier)")
        }
        
        // If an identity token was received, it can be sent to a backend server for verification
        if let identityTokenData = appleIDCredential.identityToken,
           let identityToken = String(data: identityTokenData, encoding: .utf8) {
            print("Identity Token: \(identityToken)")
            decodeIdentityToken(identityToken)

            // Send `identityToken` to your server for verification and log in the user on your system
        }
    }
    
    func decodeIdentityToken(_ token: String) {
        do {
            let jwt = try decode(jwt: token)
            if let subject = jwt.subject {
                print("User Identifier: \(subject)")
            }
            if let email = jwt.claim(name: "email").string {
                print("User Email: \(email)")
            }
            // Add additional claims as needed
        } catch {
            print("Failed to decode JWT: \(error)")
        }
    }
    
}
