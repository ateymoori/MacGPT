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
    @ObservedObject private var settingsModel = SettingsModel.shared
    
    @State private var outputText: String = ""
    let characterLimit = 1500
    @State private var isLoading: Bool = false
    @State private var selectedMode: String = "Rephrase"
    
    @State private var selectedModelKey: String = "gpt-3.5-turbo"
    let modelDisplayNames = ["GPT 3.5 Turbo": "gpt-3.5-turbo", "GPT 4": "gpt-4", "GPT 4 Turbo": "gpt-4-turbo"]

    
    
    
    @State private var correctDictation: Bool = false
    @State private var correctGrammar: Bool = false
    @State private var selectedTune: String = "dontChange"
    @State private var showingModelInfo = false
    
    @State private var translateTo: Bool = false
    @State private var selectedLanguage = "English English" // Default selection set to English

    @EnvironmentObject var pinStatus: PinStatus  // Add this line
    @State private var isPinned: Bool = false
    
    init() {
        let defaultModeName = settingsModel.firstModeName.isEmpty ? "Rephrase" : settingsModel.firstModeName
        _selectedMode = State(initialValue: defaultModeName)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("iChatGPT")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: togglePin) {
                    Image(systemName: isPinned ? "pin.fill" : "pin.slash.fill")
                }
                .buttonStyle(BorderlessButtonStyle())
                
                
                
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
            
            // "Translate to" checkbox and language picker
            HStack {
                Toggle("To Language", isOn: $translateTo)
                Picker("", selection: $selectedLanguage) {
                    ForEach(getLanguages(), id: \.self) { language in
                        Text(language).tag(language)
                    }
                }
                .disabled(!translateTo)
            }
            .padding(.top, 20)
            
            // Checkboxes for dictation and grammar correction
            HStack {
                Toggle("Correct Dictation", isOn: $correctDictation)
                Toggle("Correct Grammar", isOn: $correctGrammar)
            }
            
            // Radio buttons for tune selection
            Picker("Tune", selection: $selectedTune) {
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
                            
                            Button(action: {
                                self.speak(text: sharedTextModel.inputText)
                            }) {
                                Image(systemName: "speaker.3.fill")
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


         let modelKey = modelDisplayNames[selectedModelKey] ?? "gpt-3.5-turbo"

         var finalPrompt = sharedTextModel.inputText
         var actions = [String]()

         // Add translation directive if necessary
         if translateTo {
             let languageName = selectedLanguage.components(separatedBy: " ").first ?? "English"
             actions.append("Translate this text to \(languageName)")
         }

         // Add grammar correction if necessary
         if correctGrammar {
             actions.append("Correct the grammar")
         }

         // Add dictation correction if necessary
         if correctDictation {
             actions.append("Correct the dictation")
         }

         // Add tone adjustment if necessary
         if selectedTune != "dontChange" {
             actions.append("Change the tone to \(selectedTune)")
         }

         if !actions.isEmpty {
             finalPrompt = "\(actions.joined(separator: " and ")): {{ \(finalPrompt) }}"
         }

         // Log the final message and prompt
         print("Final Message: \(sharedTextModel.inputText)")
         print("Final Prompt: \(finalPrompt)")
        OpenAIManager.shared.askQuestion(model: modelKey, prompt: finalPrompt) { result in
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
        AppWindowManager.shared.showSettingsWindow()
        // SettingsWindowManager.shared.showSettingsWindow()
    }
    func showReminder() {
        AppWindowManager.shared.showReminderWindow()
    }
    
    private let speechSynthesizer = AVSpeechSynthesizer()
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "sv-SE")
        
        // Stop previous speech before starting the new one
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
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
    private func togglePin() {
        isPinned.toggle()
        pinStatus.isPinned = isPinned
    }
}

class PinStatus: ObservableObject {
    @Published var isPinned: Bool = false
}
