//
//  ChatView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import SwiftUI

struct ChatView: View {
    @ObservedObject private var sharedTextModel = SharedTextModel.shared
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    @State private var outputText: String = ""
    let characterLimit = 1500
    @State private var isLoading: Bool = false
    @State private var selectedMode: String = "Rephrase"
    
    @State private var selectedModelKey: String = "gpt-3.5-turbo"
    let modelDisplayNames = ["GPT 3.5 Turbo": "gpt-3.5-turbo", "GPT 4": "gpt-4", "GPT 4 Turbo": "gpt-4-turbo"]
    
    
    @State private var showingModelInfo = false
    
    
    init() {
        // Ensuring the first mode name is not empty and is one of the Picker's tags
        let defaultModeName = settingsModel.firstModeName.isEmpty ? "Rephrase" : settingsModel.firstModeName
        _selectedMode = State(initialValue: defaultModeName)
    }
    
    var body: some View {
        VStack {
            
            HStack {
                Text("iChatGPT")
                    .font(.title2) // Smaller font size for the title
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    // ... [Existing elements]
                    
                    // New Button for Floating Window
                    Button(action: showReminder) {
                        Image(systemName: "plus") // Example icon, replace with your choice
                    }
                    .padding(.top, 10)
                    .buttonStyle(BorderlessButtonStyle())
                    
                    // Existing Settings Button
                    Button(action: showSettings) {
                        Image(systemName: "gearshape.fill")
                    }
                    .padding(.top, 10)
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding([.top, .horizontal])
            }
            .padding([.top, .horizontal])
            
            
            
            HStack {
                Picker("Model", selection: $selectedModelKey) {
                    ForEach(modelDisplayNames.keys.sorted(), id: \.self) { key in
                        Text(key).tag(modelDisplayNames[key]!)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Button(action: { showingModelInfo = true }) {
                    Image(systemName: "info.circle")
                }
                .popover(isPresented: $showingModelInfo) {
                    ModelInfoView()
                }
            }
            .padding()
            
            // Mode Selection (Rephrase / Question)
            Picker("Mode", selection: $selectedMode) {
                Text(settingsModel.firstModeName.isEmpty ? "Rephrase" : settingsModel.firstModeName)
                    .tag(settingsModel.firstModeName.isEmpty ? "Rephrase" : settingsModel.firstModeName)
                Text(settingsModel.secondModeName.isEmpty ? "Question" : settingsModel.secondModeName)
                    .tag(settingsModel.secondModeName.isEmpty ? "Question" : settingsModel.secondModeName)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Input TextEditor
            TextEditor(text: $sharedTextModel.inputText)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
                .font(.body)
                .padding(8)
                .lineSpacing(8)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: pasteClipboard) {
                                Image(systemName: "arrow.right.doc.on.clipboard")
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
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
                .font(.body)
                .padding(8)
                .lineSpacing(8)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: copyToClipboard) {
                                Image(systemName: "doc.on.doc")
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
        
        let systemMessage = selectedMode == settingsModel.firstModeName ? settingsModel.firstModePrompt : settingsModel.secondModePrompt
        
        let modelKey = modelDisplayNames[selectedModelKey] ?? "gpt-3.5-turbo" // Default to "gpt-3.5-turbo" if key not found
        
        OpenAIManager.shared.askQuestion(model: modelKey, prompt: sharedTextModel.inputText, systemMessage: systemMessage) { result in
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
    func showReminder() {
        ReminderWindowManager.shared.showReminderWindow()
    }
    
}
