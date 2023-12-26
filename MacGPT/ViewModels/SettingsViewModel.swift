//
//  SettingsViewModel.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-22.
//

import Foundation
import AuthenticationServices
import JWTDecode
import StoreKit
import Combine


class SettingsViewModel: ObservableObject {
    @Published var customHotkey: String = UserDefaults.standard.string(forKey: "CustomHotkey") ?? "Cmd+Shift+6"
    @Published var isHotkeyInputFocused: Bool = false
 
    
    @Published var userIdentifier: String = UserDefaults.standard.string(forKey: "userIdentifier") ?? ""
    @Published var userName: String = UserDefaults.standard.string(forKey: "userName") ?? ""
    @Published var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    @Published var identityToken: String = UserDefaults.standard.string(forKey: "identityToken") ?? ""
    @Published var authorizationCode: String = UserDefaults.standard.string(forKey: "authorizationCode") ?? ""
    @Published var isUserLoggedIn: Bool = UserDefaults.standard.string(forKey: "userIdentifier") != nil
    @Published var appVersion: String
    @Published var products: [SKProduct] = []
    @Published var isTransactionInProgress: Bool = false
    @Published var transactionStatusMessage: String = ""
    private var cancellables = Set<AnyCancellable>()
    private let subscriptionsService = SubscriptionsService.shared
    private let apiClient = APIClient()
    @Published var isLoading: Bool = false
    
    init() {
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        setupSubscriptionsService()
        fetchProducts()
        sync()
    }
    
    private func setupSubscriptionsService() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleProductUpdate), name: .didReceiveProducts, object: nil)
    }
    
    func fetchProducts() {
        subscriptionsService.requestProducts()
    }
    
    @objc private func handleProductUpdate(notification: Notification) {
        guard let products = notification.object as? [SKProduct] else { return }
        DispatchQueue.main.async {
            self.products = products
        }
    }
    
    func purchaseProduct(_ product: SKProduct) {
        isTransactionInProgress = true
        subscriptionsService.buyProduct(product)
    }
    
    func handleTransactionUpdate(_ notification: Notification) {
        guard let status = notification.object as? String else {
            transactionStatusMessage = "Transaction completed"
            return
        }
        transactionStatusMessage = status
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func prepareSignInRequest(request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    func handleSignInResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            guard let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential else {
                return
            }
            handleAuthorizationAppleIDCredential(appleIDCredential)
            sync()
        case .failure(let error):
            print("Authentication failed: \(error.localizedDescription)")
        }
    }
    
    private func handleAuthorizationAppleIDCredential(_ appleIDCredential: ASAuthorizationAppleIDCredential) {
        updateUserInfoFromCredential(appleIDCredential)
        saveUserIdentifier(appleIDCredential.user)
        identityToken = decodeIdentityToken(appleIDCredential.identityToken)
        authorizationCode = decodeAuthorizationCode(appleIDCredential.authorizationCode)
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
        guard let tokenData = tokenData, let token = String(data: tokenData, encoding: .utf8) else { return "" }
        UserDefaults.standard.set(token, forKey: "identityToken")
        return token
    }
    
    private func decodeAuthorizationCode(_ codeData: Data?) -> String {
        guard let codeData = codeData, let code = String(data: codeData, encoding: .utf8) else { return "" }
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
    
    func sync() {
        let requestData = UserRequest(
            userEmail: userEmail,
            userName: userName,
            userIdentifier: userIdentifier
        )
        
        guard let encodedRequest = try? JSONEncoder().encode(requestData) else {
            return // Consider handling encoding error
        }
        
        apiClient.postData(to: "user", body: encodedRequest) { [weak self] result in
            // Handle response
        }
    }
    
    
    
    func saveCustomHotkey() {
        UserDefaults.standard.set(customHotkey, forKey: "CustomHotkey")
    }
    
    // Function to load the custom hotkey when the view appears
    func loadCustomHotkey() {
        if let savedCustomHotkey = UserDefaults.standard.string(forKey: "CustomHotkey") {
            customHotkey = savedCustomHotkey
        }
    }
}

extension Notification.Name {
    static let didReceiveProducts = Notification.Name("didReceiveProducts")
    static let didUpdateTransaction = Notification.Name("didUpdateTransaction")
}
