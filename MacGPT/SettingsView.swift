//
//  SettingsView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//
import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsModel = SettingsModel.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TextField("OpenAI API Key", text: $settingsModel.apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            TextEditor(text: $settingsModel.initialPrompt)
                .frame(maxHeight: 150)
                .border(Color.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            Button("Save Settings") {
                settingsModel.saveApiKey()
                settingsModel.saveInitialPrompt()
                SettingsWindowManager.shared.closeSettingsWindow()
            }
            .padding()
        }
        .padding()
        .frame(width: 500, height: 300)
    }
}
