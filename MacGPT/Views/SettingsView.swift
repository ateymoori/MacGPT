//
//  SettingsView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//
 
import SwiftUI
import AuthenticationServices
 

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                if viewModel.isUserLoggedIn {
                    userDetailsView
                    logOffButton
                } else {
                    signInWithAppleButton
                }
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 735)
    }

    private var userDetailsView: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("User Identifier: \(viewModel.userIdentifier)")
               Text("User Name: \(viewModel.userName)")
               Text("User Email: \(viewModel.userEmail)")
               Text("Identity Token: \(viewModel.identityToken)")
               Text("Authorization Code: \(viewModel.authorizationCode)")
        }
    }

    private var logOffButton: some View {
        Button("Log Off", action: viewModel.handleLogOff)
            .padding()
    }

    private var signInWithAppleButton: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: viewModel.prepareSignInRequest,
            onCompletion: viewModel.handleSignInResult
        )
        .frame(height: 44)
        .padding()
    }
}
