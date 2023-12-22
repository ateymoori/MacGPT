//
//  SettingsViewModel.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-22.
//

import Foundation
import AuthenticationServices
import JWTDecode

class SettingsViewModel: ObservableObject {
    @Published var userIdentifier: String = UserDefaults.standard.string(forKey: "userIdentifier") ?? ""
    @Published var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @Published var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    @Published var identityToken: String = UserDefaults.standard.string(forKey: "identityToken") ?? ""
    @Published var authorizationCode: String = UserDefaults.standard.string(forKey: "authorizationCode") ?? ""
    @Published var isUserLoggedIn: Bool = UserDefaults.standard.string(forKey: "userIdentifier") != nil


    func prepareSignInRequest(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }

    func handleSignInResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                handleAuthorizationAppleIDCredential(appleIDCredential)
            }
        case .failure(let error):
            print("Authentication failed: \(error.localizedDescription)")
        }
    }

    private func handleAuthorizationAppleIDCredential(_ appleIDCredential: ASAuthorizationAppleIDCredential) {
        DispatchQueue.main.async {
            self.updateUserInfoFromCredential(appleIDCredential)
            self.saveUserIdentifier(appleIDCredential.user)
            self.identityToken = self.decodeIdentityToken(appleIDCredential.identityToken)
            self.authorizationCode = self.decodeAuthorizationCode(appleIDCredential.authorizationCode)
        }
    }

    private func updateUserInfoFromCredential(_ credential: ASAuthorizationAppleIDCredential) {
        if let fullName = credential.fullName {
            userName = [fullName.givenName, fullName.familyName].compactMap { $0 }.joined(separator: " ")
            UserDefaults.standard.set(userName, forKey: "userName")
        }
        if let email = credential.email {
            userEmail = email
            UserDefaults.standard.set(userEmail, forKey: "userEmail")
        }
    }

    private func saveUserIdentifier(_ identifier: String) {
        UserDefaults.standard.set(identifier, forKey: "userIdentifier")
        isUserLoggedIn = true
    }
    private func decodeIdentityToken(_ tokenData: Data?) -> String {
        guard let tokenData = tokenData,
              let token = String(data: tokenData, encoding: .utf8) else { return "" }
        UserDefaults.standard.set(token, forKey: "identityToken")
        return token
    }

    private func decodeAuthorizationCode(_ codeData: Data?) -> String {
        guard let codeData = codeData,
              let code = String(data: codeData, encoding: .utf8) else { return "" }
        UserDefaults.standard.set(code, forKey: "authorizationCode")
        return code
    }
    func handleLogOff() {
        UserDefaults.standard.removeObject(forKey: "userName")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        UserDefaults.standard.removeObject(forKey: "userIdentifier")
        userName = ""
        userEmail = ""
        isUserLoggedIn = false
    }
}
