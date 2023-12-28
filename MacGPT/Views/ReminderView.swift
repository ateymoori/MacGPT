//
//  ReminderView.swift .swift
//  MacGPT
//
//  Created by AmirHossein Teymoori on 2023-12-07.
//

import SwiftUI
import AVFoundation
import KeyboardShortcuts

struct ReminderView: View {
    
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: closeView) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .background(Color.clear)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. To set iLexicon to open at startup, add it to 'Login Items' in:\nSystem Preferences > Generals > Login Items.")
                        .lineSpacing(4)
                    Button("Open Login Items") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.LoginItems-Settings.extension") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .padding(.top, 8)
                    Image("login_items")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                    
                    Text("2. iLexicon needs permission to capture the screen for OCR functionality. \nBy default, you can use Command + Shift + 2 to capture screen and Translate texts. Please enable screen recording for iLexicon in: \nSystem Preferences > Privacy > Screen Recording.")
                        .lineSpacing(4)
                        .padding(.top, 20)
                    Button("Open Screen Recording") {
                        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .padding(.top, 8)
                    Image("capture_permission")
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                    
                    settingsScreen()
                }
                .padding([.leading, .bottom, .trailing])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75))
        .cornerRadius(2)
    }
    private func closeView() {
        AppWindowService.shared.closeReminderWindow()
    }
    
}


extension KeyboardShortcuts.Name {
    static let toggleUnicornMode = Self("toggleUnicornMode", default: Shortcut(.two, modifiers: [.command, .shift]))
}

struct settingsScreen: View {
    @State private var startAtLogin = UserDefaults.standard.bool(forKey: "StartAtLogin")
    
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("3. Capture Screen (OCR) HotKey:", name: .toggleUnicornMode)
        }
    }
}

