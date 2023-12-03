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
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                LabelledTextField(label: "OpenAI API Key", text: $settingsModel.apiKey)
                LabelledTextField(label: "First Mode Name", text: $settingsModel.firstModeName)
                LabelledTextEditor(label: "First Mode Prompt", text: $settingsModel.firstModePrompt)

                Divider()

                LabelledTextField(label: "Second Mode Name", text: $settingsModel.secondModeName)
                LabelledTextEditor(label: "Second Mode Prompt", text: $settingsModel.secondModePrompt)
            }
            .padding()
        }
        .frame(minWidth: 500, minHeight: 735)
    }
}

struct LabelledTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(label).bold()
            TextField("", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(EdgeInsets(top: 4, leading: 1, bottom: 1, trailing: 1))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary, lineWidth: 1)
                )
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
                .frame(minHeight: 200)
                .padding(EdgeInsets(top: 2, leading: 1, bottom: 1, trailing: 1))
                .lineSpacing(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.secondary, lineWidth: 1)
                )
        }
        .padding(.bottom, 10)
    }
}

