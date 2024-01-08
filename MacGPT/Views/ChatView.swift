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
    @StateObject private var viewModel = ChatViewModel()
    @State private var isInputTextSpeaking = false
    @State private var isOutputTextSpeaking = false
    let speechSynthesizer = AVSpeechSynthesizer()
    let characterLimit = 2000
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            headerView
            QuestionSettingsView(viewModel: viewModel)
            inputTextView
            actionButtons
            outputTextView
            outputActions
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 30)
        .onReceive(sharedTextModel.$inputText) { newText in
            viewModel.inputText = newText
        }
        .onAppear { viewModel.getUser() }
    }
    
    private var headerView: some View {
        HStack {
            Text("i Lexicon Pro")
                .font(.title2)
                .fontWeight(.bold)
            
            if viewModel.isPremiumUser {
                Image("premium-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 13)
            }
            
            Spacer()
            
            HStack {
                pinButton
                reminderButton
            }
        }
    }
    
    private var pinButton: some View {
        Button(action: togglePin) {
            Image(systemName: PinStatus.shared.isPinned ? "pin.fill" : "pin.slash.fill")
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var reminderButton: some View {
        Button(action: showReminder) {
            Image(systemName: "questionmark.circle")
        }
        .buttonStyle(BorderlessButtonStyle())
    }
    
    private var inputTextView: some View {
        TextEditor(text: $viewModel.inputText.onChange(limitText))
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
            .font(.body)
            .padding(4)
            .lineSpacing(5)
            .border(Color.secondary)
    }
    
    private var actionButtons: some View {
        HStack {
            LoadingButton(text: "Proceed", isLoading: viewModel.isLoading, action: viewModel.translateText)

            Spacer()
            Text("\(viewModel.inputText.count)/\(characterLimit)")
                .padding(.trailing, 8)
            
            Button(action: pasteClipboard) {
                Image(systemName: "arrow.right.doc.on.clipboard")
            }
            .buttonStyle(BorderlessButtonStyle())
            
            speakButton(for: viewModel.inputText, isSpeaking: $isInputTextSpeaking, isInputText: true)

        }
        .padding([.bottom, .trailing], 0)
    }
    
    private var outputTextView: some View {
        TextEditor(text: $viewModel.outputText)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
            .font(.body)
            .padding(4)
            .lineSpacing(5)
            .border(Color.secondary)
    }
    
    private var outputActions: some View {
        HStack {
            Spacer()
            
            Button(action: { copyToClipboard(text: viewModel.outputText) }) {
                Image(systemName: "doc.on.clipboard.fill")
            }
            .buttonStyle(BorderlessButtonStyle())
            
            speakButton(for: viewModel.outputText, isSpeaking: $isOutputTextSpeaking, isInputText: false)
        }
        .padding([.bottom, .trailing], 0)
    }
    
    private func speakButton(for text: String, isSpeaking: Binding<Bool>, isInputText: Bool) -> some View {
        Button(action: {
            if isSpeaking.wrappedValue {
                stopSpeaking(inputText: isInputText)
            } else {
                speakText(text: text, inputText: isInputText)
            }
        }) {
            Image(systemName: isSpeaking.wrappedValue ? "stop.fill" : "speaker.wave.2.fill")
        }
        .buttonStyle(BorderlessButtonStyle())
        .foregroundColor(isLanguageSupported(text: text) ? .green : .red)
    }
    
    private func togglePin() {
        PinStatus.shared.isPinned.toggle()
    }
    
    private func pasteClipboard() {
        sharedTextModel.inputText = NSPasteboard.general.string(forType: .string) ?? ""
    }
    
    private func copyToClipboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    private func showReminder() {
        AppWindowService.shared.showReminderWindow()
    }
    
    private func speakText(text: String, inputText: Bool) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: detectLanguage(text: text))
        speechSynthesizer.speak(utterance)
        if inputText {
            isInputTextSpeaking = true
        } else {
            isOutputTextSpeaking = true
        }
    }
    
    private func stopSpeaking(inputText: Bool) {
        speechSynthesizer.stopSpeaking(at: .immediate)
        if inputText {
            isInputTextSpeaking = false
        } else {
            isOutputTextSpeaking = false
        }
    }
    
    private func detectLanguage(text: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        return tagger.dominantLanguage ?? "en-US"
    }
    
    private func isLanguageSupported(text: String) -> Bool {
        let detectedLanguage = detectLanguage(text: text)
        return AVSpeechSynthesisVoice.speechVoices().contains { $0.language.starts(with: detectedLanguage) }
    }
    
    private func limitText(_ text: String) {
        viewModel.inputText = String(text.prefix(characterLimit))
    }
}


class PinStatus: ObservableObject {
    static let shared = PinStatus()
    @Published var isPinned: Bool = false
}

struct QuestionSettingsView: View {
    @ObservedObject var viewModel: ChatViewModel
    @StateObject var languageList = LanguageListModel()
    
    var body: some View {
        VStack {
            LanguageSelectionView(languageList: viewModel.languageListModel, selectedLanguage: $viewModel.selectedLanguage)
                .onChange(of: viewModel.selectedLanguage) { newLanguage in
                    viewModel.selectLanguage(code: newLanguage?.id ?? "")
                }
            
            dictationAndGrammarToggles
            
            tonePicker
        }
    }
    
    private var dictationAndGrammarToggles: some View {
        HStack {
            Toggle("Correct Dictation", isOn: $viewModel.config.correctDictation.onChange(applyConfigurationChange))
            Toggle("Correct Grammar", isOn: $viewModel.config.correctGrammar.onChange(applyConfigurationChange))
            Toggle("Summarize", isOn: $viewModel.config.summarizeText.onChange(applyConfigurationChange))
            Spacer()
        }
    }
    
    private var tonePicker: some View {
        Picker("Tune", selection: $viewModel.config.selectedTone) {
            ForEach(Tone.allCases, id: \.self) { tone in
                Text(tone.displayName).tag(tone.rawValue)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    
    private func applyConfigurationChange(_ value: Bool) {
        viewModel.config.toDifferentLanguage = value
        viewModel.saveConfiguration()
    }
}
