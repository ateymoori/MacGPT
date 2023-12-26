//
//  ChatView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import SwiftUI
import AVFoundation

extension View {
    func configureTextEditor() -> some View {
        self
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
            .font(.body)
            .padding(4)
            .lineSpacing(5)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "icon_name")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 8)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Characters count / Limit")
                    }
                    .padding(.trailing, 8)
                    .padding(.bottom, 8)
                }, alignment: .topTrailing
            )
            .border(Color.secondary)
    }
}

// Extension to detect changes in state
extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}


struct ChatView: View {
    @ObservedObject private var sharedTextModel = SharedTextModel.shared
    
    @State private var outputText: String = ""
    let characterLimit = 1500
    @State private var isLoading: Bool = false
    @ObservedObject private var pinStatus = PinStatus.shared
    
    
    @StateObject private var viewModel = ChatViewModel()
    
    
    init() {
          viewModel.getUser()
      }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("i Lexicon Pro")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(viewModel.isPremiumUser ? "Premium" : "Free")
                        .font(.subheadline)
                        .foregroundColor(viewModel.isPremiumUser ? Color.green : Color.orange)
                }
                
                
                Spacer()
                
                HStack {
                    Button(action: togglePin) {
                        Image(systemName: pinStatus.isPinned ? "pin.fill" : "pin.slash.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: showReminder) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    Button(action: showSettings) {
                        Image(systemName: "gearshape.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            .padding(.horizontal)
            
            ToggleSettingsView(viewModel: viewModel)
            
            TextEditor(text: $viewModel.inputText)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
                .font(.body)
                .padding(4)
                .lineSpacing(5)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: pasteClipboard) {
                                Image(systemName: "arrow.right.doc.on.clipboard")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.trailing, 8)
                        }
                        Spacer()
                        HStack {
                            Spacer()
                            Text("\(sharedTextModel.inputText.count)/\(characterLimit)")
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                    }, alignment: .topTrailing
                )
                .border(Color.secondary)
            
            HStack {
                Button(action: {
                    
                    viewModel.translateText()
                }) {
                    Text("Proceed")
                }
                .padding()
                
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.75)
                        .padding(.leading, 8)
                }
            }
            
            TextEditor(text: $viewModel.outputText)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
                .font(.body)
                .padding(4)
                .lineSpacing(5)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: copyToClipboard) {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            .padding(.trailing, 8)
                        }
                        Spacer()
                    }, alignment: .topTrailing
                )
                .border(Color.secondary)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .onReceive(sharedTextModel.$inputText) { newText in
            viewModel.inputText = newText
        }

    }
    
    private func togglePin() {
        pinStatus.isPinned.toggle()
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
        AppWindowService.shared.showSettingsWindow()
    }
    func showReminder() {
        AppWindowService.shared.showReminderWindow()
    }
    
}

class PinStatus: ObservableObject {
    static let shared = PinStatus()
    @Published var isPinned: Bool = false
}


struct ToggleSettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            HStack {
                Toggle("Translate", isOn: $viewModel.config.translateTo
                    .onChange { viewModel.config.translateTo = $0; viewModel.saveConfiguration() })
                Picker("Language", selection: $viewModel.config.selectedLanguage) {
                    ForEach(viewModel.getLanguages(), id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                .disabled(!viewModel.config.translateTo)
            }
            
            HStack {
                Toggle("Correct Dictation", isOn: $viewModel.config.correctDictation
                    .onChange { viewModel.config.correctDictation = $0; viewModel.saveConfiguration() })
                Toggle("Correct Grammar", isOn: $viewModel.config.correctGrammar
                    .onChange { viewModel.config.correctGrammar = $0; viewModel.saveConfiguration() })
                
                Toggle("Summarize", isOn: $viewModel.config.summarizeText
                    .onChange { viewModel.config.summarizeText = $0; viewModel.saveConfiguration() })
                Spacer()
            }
            
            Picker("Tune", selection: $viewModel.config.selectedTone) {
                ForEach(Tone.allCases, id: \.self) { tone in
                    Text(tone.displayName).tag(tone.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
}
