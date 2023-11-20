//
//  SettingsView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//
import SwiftUI

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settingsModel = SettingsModel.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // OpenAI API Key
            LabelledTextField(label: "OpenAI API Key", text: $settingsModel.apiKey)

            // First Mode Name and Prompt
            LabelledTextField(label: "First Mode Name", text: $settingsModel.firstModeName)
            LabelledTextEditor(label: "First Mode Prompt", text: $settingsModel.firstModePrompt)

            // Second Mode Name and Prompt
            LabelledTextField(label: "Second Mode Name", text: $settingsModel.secondModeName)
            LabelledTextEditor(label: "Second Mode Prompt", text: $settingsModel.secondModePrompt)

            // Save Button
            Button("Save Settings") {
                SettingsWindowManager.shared.closeSettingsWindow()
            }
            .padding()
        }
        .padding()
        .frame(width: 500, height: 600)
    }
}

struct LabelledTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).bold()
            TextField(label, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.bottom, 5)
    }
}

struct LabelledTextEditor: View {
    let label: String
    @Binding var text: String

    var body: some View {
            VStack(alignment: .leading) {
                Text(label).bold()
                TextEditor(text: $text)
                    .frame(maxHeight: 100)
                    .padding(10) // Added padding inside the TextEditor
                    .border(Color.secondary)
            }
            .padding(.bottom, 10)
        }
}
