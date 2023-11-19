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
    @State private var selectedMode: String = "Rephrase"
    let modes = ["Rephrase", "Question"]
    
    var body: some View {
            VStack {
  
                HStack {
                            Text("Mac GPT")
                                .font(.title2) // Smaller font size for the title
                                .fontWeight(.bold)

                            Spacer()

                            Button(action: showSettings) {
                                Image(systemName: "gearshape.fill")
                            }
                            .padding(.top, 10)
                            .buttonStyle(BorderlessButtonStyle())
                        }
                        .padding([.top, .horizontal])
                
                
                
                // Mode Selection (Rephrase / Question)
                   Picker("Mode", selection: $selectedMode) {
                       ForEach(modes, id: \.self) {
                           Text($0)
                       }
                   }
                   .pickerStyle(SegmentedPickerStyle())
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
                HStack {
                    Button(action: {
                        self.isLoading = true
                        askChatGPT()
                    }) {
                        Text("Ask ChatGPT")
                    }
                    .padding()

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.75)
                            .padding(.leading, 8)
                    }
                }

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

        
        let systemMessage: String
        if selectedMode == "Rephrase" {
            systemMessage = "As an AI proficient in Swedish, English, and Persian, your task is to identify the language of any phrase I provide. If the phrase is in Swedish or Persian, translate it into English and respond only with the English translation. Refrain from adding any extra commentary. If the phrase is in English, review its spelling, grammar, and tone. Your objective is to correct any grammatical or spelling errors, while preserving the original meaning, logic, and tone of the phrase. Provide the corrected version as your response"
        } else { // "Question" mode
            systemMessage = "As an AI assistant equipped with knowledge of modern trends and extensive data, your role is to respond to my queries with clarity, directness, and conciseness. Provide answers that are straightforward and detailed, yet brief, avoiding any extraneous information. Just focus on addressing the question at hand. Before responding, identify the language of my question and use the same language for your answer"
        }
        
        OpenAIManager.shared.askQuestion(prompt: sharedTextModel.inputText, systemMessage: systemMessage) { result in
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
