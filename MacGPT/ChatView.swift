//
//  ChatView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject private var sharedTextModel = SharedTextModel.shared
    @State private var outputText: String = ""
    let characterLimit = 1500
    @State private var isLoading: Bool = false
    
    
    var body: some View {
            VStack {
  
                Text("Mac GPT")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                // Input TextEditor
                TextEditor(text: $sharedTextModel.inputText)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
                    .padding(4)
                    .lineSpacing(4)
                    .overlay(
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: pasteClipboard) {
                                    Image(systemName: "doc.on.clipboard.fill")
                                        .padding(.top, 10)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.trailing, 8)
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(sharedTextModel.inputText.count)/\(characterLimit)")
                                    .padding(.trailing, 8)
                                    .padding(.bottom, 8)
                            }
                        }, alignment: .topTrailing
                    )
                    .border(Color.secondary)
                    .padding()

                // Ask ChatGPT Button with Loading Indicator
                Button(action: {
                    self.isLoading = true
                    askChatGPT()
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1)
                        }
                        Text("Ask ChatGPT")
                    }
                }
                .padding()

                // Output TextEditor
                TextEditor(text: $outputText)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150, maxHeight: .infinity)
                    .padding(4)
                    .lineSpacing(4)
                    .overlay(
                        VStack {
                            HStack {
                                Spacer()
                                Button(action: copyToClipboard) {
                                    Image(systemName: "doc.on.doc.fill")
                                        .padding(.top, 10)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .padding(.trailing, 8)
                            }
                            Spacer()
                        }, alignment: .topTrailing
                    )
                    .border(Color.secondary)
                    .padding()

                Spacer()
            }
        }
 
    func askChatGPT() {
        isLoading = true
        let settingsModel = SettingsModel()
        OpenAIManager.shared.askQuestion(prompt: sharedTextModel.inputText, systemMessage: settingsModel.initialPrompt) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    self.outputText = response
                case .failure(let error):
                    self.outputText = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func pasteClipboard() {
        if let clipboardContents = NSPasteboard.general.string(forType: .string) {
            sharedTextModel.inputText = clipboardContents
        }
    }

    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputText, forType: .string)
    }

    func showSettings() {
        SettingsWindowManager.shared.showSettingsWindow()
    }
}
