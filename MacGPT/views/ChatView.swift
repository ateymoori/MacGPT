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
                        Button(action: {} /* placeholder for action */) {
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
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    @State private var outputText: String = ""
    let characterLimit = 1500
    @State private var isLoading: Bool = false
    
    
    // UserDefaults keys
    private let userDefaults = UserDefaults.standard
    private let correctDictationKey = "correctDictation"
    private let correctGrammarKey = "correctGrammar"
    private let selectedTuneKey = "selectedTune"
    private let translateToKey = "translateTo"
    private let selectedLanguageKey = "selectedLanguage"
    
    // User configurations with UserDefaults
    @State private var correctDictation: Bool = UserDefaults.standard.bool(forKey: "correctDictation")
    @State private var correctGrammar: Bool = UserDefaults.standard.bool(forKey: "correctGrammar")
    @State private var selectedTune: String = UserDefaults.standard.string(forKey: "selectedTune") ?? "dontChange"
    @State private var translateTo: Bool = UserDefaults.standard.bool(forKey: "translateTo")
    @State private var selectedLanguage: String = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "English English"
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header with app title and buttons for reminder and settings
            HStack {
                Text("iChatGPT")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                HStack {
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
            
            // Translation, Dictation, and Grammar toggles
            HStack {
                Toggle("To Language", isOn: $translateTo.onChange(saveTranslateTo))
                Picker("Select Language", selection: $selectedLanguage.onChange(saveSelectedLanguage)) {
                    ForEach(getLanguages(), id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                .disabled(!translateTo)
            }
            .padding(.top, 20)
            
            HStack {
                Toggle("Correct Dictation", isOn: $correctDictation.onChange(saveCorrectDictation))
                Toggle("Correct Grammar", isOn: $correctGrammar.onChange(saveCorrectGrammar))
            }
            
            Picker("Tune", selection: $selectedTune.onChange(saveSelectedTune)) {
                Text("Don't Change").tag("dontChange")
                Text("Friendly").tag("friendly")
                Text("Formal").tag("formal")
                Text("Negative").tag("negative")
                Text("Positive").tag("positive")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            TextEditor(text: $sharedTextModel.inputText)
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
            
            TextEditor(text: $outputText)
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
        .padding(.top, 10)
    }
    
    
    
    func askChatGPT() {
        isLoading = true
        
        var finalPrompt = sharedTextModel.inputText
        var actions = [String]()
        
        if translateTo {
            let languageName = selectedLanguage.components(separatedBy: " ").first ?? "English"
            actions.append("Translate this text to \(languageName)")
        }
        
        if correctGrammar {
            actions.append("Correct the grammar")
        }
        
        if correctDictation {
            actions.append("Correct the dictation")
        }
        
        if selectedTune != "dontChange" {
            actions.append("Change the tone to \(selectedTune)")
        }
        
        if !actions.isEmpty {
            finalPrompt = "\(actions.joined(separator: " and ")): {{ \(finalPrompt) }}"
        }
        
        OpenAIManager.shared.askQuestion( prompt: finalPrompt) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let response):
                    self.outputText = response.answer
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
        AppWindowManager.shared.showSettingsWindow()
    }
    func showReminder() {
        AppWindowManager.shared.showReminderWindow()
    }
    
    func getLanguages() -> [String] {
        return [
            "Afrikaans Afrikaans",
            "Albanian Shqip",
            "Amharic አማርኛ",
            "Arabic العربية",
            "Armenian Հայերեն",
            "Azerbaijani Azərbaycanca",
            "Basque Euskara",
            "Belarusian Беларуская",
            "Bengali বাংলা",
            "Bosnian Bosanski",
            "Bulgarian Български",
            "Catalan Català",
            "Cebuano Binisaya",
            "Chichewa Chichewa",
            "Chinese 中文",
            "Corsican Corsu",
            "Croatian Hrvatski",
            "Czech Čeština",
            "Danish Dansk",
            "Dutch Nederlands",
            "English English",
            "Esperanto Esperanto",
            "Estonian Eesti",
            "Filipino Filipino",
            "Finnish Suomi",
            "French Français",
            "Frisian Frysk",
            "Galician Galego",
            "Georgian ქართული",
            "German Deutsch",
            "Greek Ελληνικά",
            "Gujarati ગુજરાતી",
            "Haitian Creole Kreyòl ayisyen",
            "Hausa Hausa",
            "Hawaiian ʻŌlelo Hawaiʻi",
            "Hebrew עברית",
            "Hindi हिन्दी",
            "Hmong Hmong",
            "Hungarian Magyar",
            "Icelandic Íslenska",
            "Igbo Igbo",
            "Indonesian Bahasa Indonesia",
            "Irish Gaeilge",
            "Italian Italiano",
            "Japanese 日本語",
            "Javanese Basa Jawa",
            "Kannada ಕನ್ನಡ",
            "Kazakh Қазақ тілі",
            "Khmer ភាសាខ្មែរ",
            "Kinyarwanda Ikinyarwanda",
            "Korean 한국어",
            "Kurdish (Kurmanji) Kurdî",
            "Kyrgyz Кыргызча",
            "Lao ພາສາລາວ",
            "Latin Latina",
            "Latvian Latviešu",
            "Lithuanian Lietuvių",
            "Luxembourgish Lëtzebuergesch",
            "Macedonian Македонски",
            "Malagasy Malagasy",
            "Malay Bahasa Melayu",
            "Malayalam മലയാളം",
            "Maltese Malti",
            "Maori Māori",
            "Marathi मराठी",
            "Mongolian Монгол",
            "Myanmar (Burmese) ဗမာ",
            "Nepali नेपाली",
            "Norwegian Norsk",
            "Odia (Oriya) ଓଡ଼ିଆ",
            "Pashto پښتو",
            "Persian فارسی",
            "Polish Polski",
            "Portuguese Português",
            "Punjabi ਪੰਜਾਬੀ",
            "Romanian Română",
            "Russian Русский",
            "Samoan Gagana fa'a Sāmoa",
            "Scots Gaelic Gàidhlig",
            "Serbian Српски",
            "Sesotho Sesotho",
            "Shona Shona",
            "Sindhi سنڌي",
            "Sinhala සිංහල",
            "Slovak Slovenčina",
            "Slovenian Slovenščina",
            "Somali Soomaali",
            "Spanish Español",
            "Sundanese Basa Sunda",
            "Swahili Kiswahili",
            "Swedish Svenska",
            "Tajik Тоҷикӣ",
            "Tamil தமிழ்",
            "Tatar Татарча",
            "Telugu తెలుగు",
            "Thai ไทย",
            "Turkish Türkçe",
            "Turkmen Türkmen",
            "Ukrainian Українська",
            "Urdu اردو",
            "Uyghur ئۇيغۇرچە",
            "Uzbek O‘zbek",
            "Vietnamese Tiếng Việt",
            "Welsh Cymraeg",
            "Xhosa IsiXhosa",
            "Yiddish ייִדיש",
            "Yoruba Yorùbá",
            "Zulu isiZulu"
            
        ].sorted()
    }
    
    // Functions to save configurations
    private func saveTranslateTo(_ value: Bool) {
        userDefaults.set(value, forKey: translateToKey)
    }
    
    private func saveSelectedLanguage(_ language: String) {
        userDefaults.set(language, forKey: selectedLanguageKey)
    }
    
    private func saveCorrectDictation(_ value: Bool) {
        userDefaults.set(value, forKey: correctDictationKey)
    }
    
    private func saveCorrectGrammar(_ value: Bool) {
        userDefaults.set(value, forKey: correctGrammarKey)
    }
    
    private func saveSelectedTune(_ tune: String) {
        userDefaults.set(tune, forKey: selectedTuneKey)
    }
    
}
