//
//  ChatView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import SwiftUI
import AVFoundation

struct ChatView: View {
    @ObservedObject private var sharedTextModel = SharedTextModel.shared
    
    @State private var outputText: String = ""
    let characterLimit = 2000
    @State private var isLoading: Bool = false
    @ObservedObject private var pinStatus = PinStatus.shared
    
    @State private var isInputTextSpeaking: Bool = false
    @State private var isOutputTextSpeaking: Bool = false
    
    
    @StateObject private var viewModel = ChatViewModel()
    let speechSynthesizer = AVSpeechSynthesizer()
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                
                Text("i Lexicon Pro")
                    .font(.title2)
                    .fontWeight(.bold)
                if viewModel.isPremiumUser {
                    Image("premium-logo") // Ensure this matches your asset name
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 13)
                }
                
                Spacer()
                
                HStack {
                    Button(action: togglePin) {
                        Image(systemName: pinStatus.isPinned ? "pin.fill" : "pin.slash.fill")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    
                    Button(action: showReminder) {
                        Image(systemName: "questionmark.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    //                    Button(action: showSettings) {
                    //                        Image(systemName: "gearshape.fill")
                    //                    }
                    //                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            
            
            ToggleSettingsView(viewModel: viewModel)
            
            
            TextEditor(text: $viewModel.inputText.onChange(limitText))
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
                .font(.body)
                .padding(4)
                .lineSpacing(5)
                .border(Color.secondary)
            
            HStack {
                Spacer()
                Text("\(viewModel.inputText.count)/\(characterLimit)")
                    .padding(.trailing, 8)
                
                Button(action: pasteClipboard) {
                    Image(systemName: "arrow.right.doc.on.clipboard")
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    if self.isInputTextSpeaking {
                        self.stopSpeaking(inputText: true)
                    } else {
                        self.speakText(text: viewModel.inputText, inputText: true)
                    }
                }) {
                    Image(systemName: self.isInputTextSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(isLanguageSupported(text: viewModel.inputText) ? .green : .red)
            }
            .padding([.bottom, .trailing], 0)
            
            
            HStack {
                Button(action: {
                    
                    viewModel.translateText()
                }) {
                    Text("Proceed")
                }
                
                
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
                .border(Color.secondary)
            
            HStack {
                Spacer()
                
                Button(action: {copyToClipboard(text: viewModel.outputText)}) {
                    Image(systemName: "doc.on.clipboard.fill")
                }.buttonStyle(BorderlessButtonStyle())
                
                Button(action: {
                    if self.isOutputTextSpeaking {
                        self.stopSpeaking(inputText: false)
                    } else {
                        self.speakText(text: viewModel.outputText, inputText: false)
                    }
                }) {
                    Image(systemName: self.isOutputTextSpeaking ? "stop.fill" : "speaker.wave.2.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
                .foregroundColor(isLanguageSupported(text: viewModel.outputText) ? .green : .red)
            }
            .padding([.bottom, .trailing], 0)
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .onReceive(sharedTextModel.$inputText) { newText in
            viewModel.inputText = newText
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: .chatViewIsVisible,
                object: nil,
                queue: .main) { [weak viewModel] _ in
                    viewModel?.getUser()
                }
        }.onDisappear {
            NotificationCenter.default.removeObserver(self, name: .chatViewIsVisible, object: nil)
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
    
    func copyToClipboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    func showSettings() {
        AppWindowService.shared.showSettingsWindow()
    }
    func showReminder() {
        AppWindowService.shared.showReminderWindow()
    }
    
    
    func speakText(text: String, inputText: Bool) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: detectLanguage(text: text))
        speechSynthesizer.speak(utterance)
        if inputText {
            isInputTextSpeaking = true
        } else {
            isOutputTextSpeaking = true
        }
    }
    
    func stopSpeaking(inputText: Bool) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        if inputText {
            isInputTextSpeaking = false
        } else {
            isOutputTextSpeaking = false
        }
    }
    
    func detectLanguage(text: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        let language = tagger.dominantLanguage ?? "en-US"
        return language
    }
    func getSupportedLanguages() -> [String] {
        let voices = AVSpeechSynthesisVoice.speechVoices()
        var languageCodes: Set<String> = []
        for voice in voices {
            let code = String(voice.language.prefix(2))
            languageCodes.insert(code)
        }
        return Array(languageCodes)
    }
    
    func isLanguageSupported(text: String) -> Bool {
        let detectedLanguage = detectLanguage(text: text)
        let supportedLanguages = getSupportedLanguages()
        
        return supportedLanguages.contains(where: { $0.starts(with: detectedLanguage) })
    }
    
    private func limitText(_ text: String) {
        if text.count > characterLimit {
            viewModel.inputText = String(text.prefix(characterLimit))
        }
    }
}

class PinStatus: ObservableObject {
    static let shared = PinStatus()
    @Published var isPinned: Bool = false
}


struct ToggleSettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @StateObject var languageList = LanguageListModel()

    
    var body: some View {
        VStack {
            LanguageSelectionView( languageList: languageList).onAppear {
                print("LanguageSelectionView is appearing \(languageList.languages.count)")
            }
            
            HStack {
                Toggle("to Language", isOn: $viewModel.config.translateTo
                    .onChange { viewModel.config.translateTo = $0; viewModel.saveConfiguration() })
                                Picker("", selection: $viewModel.config.selectedLanguage) {
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
 
