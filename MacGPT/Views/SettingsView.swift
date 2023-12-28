//
//  SettingsView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import SwiftUI
import AuthenticationServices
import Cocoa
import KeyboardShortcuts


//extension KeyboardShortcuts.Name {
//    static let toggleUnicornMode = Self("toggleUnicornMode", default: Shortcut(.two, modifiers: [.command, .shift]))
//}

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var hotkeyDescription = "Press a key combination..."
    @State var screenshotHotkeys = ""
    @State private var displayedText = ""
    
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if viewModel.isUserLoggedIn {
                        userDetailsView
                        logOffButton
                    } else {
                        signInWithAppleButton
                    }
                    
                   // settingsScreen()
                    
                }
                .padding()
            }
            
            Spacer()
            
            Text("Version: \(viewModel.appVersion)")
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
        .onAppear {
            viewModel.sync()
        }
        .frame(minWidth: 500, minHeight: 400)
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

//struct settingsScreen: View {
//    @State private var startAtLogin = UserDefaults.standard.bool(forKey: "StartAtLogin")
//
//    var body: some View {
//        Form {
//            KeyboardShortcuts.Recorder("Capture Screen (OCR) :", name: .toggleUnicornMode)
//            
//            Toggle("Start at Login", isOn: $startAtLogin)
//                           .onChange(of: startAtLogin) { value in
//                               UserDefaults.standard.set(value, forKey: "StartAtLogin")
//                              // SMLoginItemSetEnabled("com.yourapp.helper" as CFString, value)
//                           }
//        }
//    }
//}
