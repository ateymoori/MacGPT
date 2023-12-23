//
//  ChatViewModel.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation
import Combine
import AppKit

class ChatViewModel: ObservableObject {
    @Published var inputText: String = ""
    @Published var outputText: String = ""
    @Published var isLoading: Bool = false
    @Published var config: ChatViewConfigurationmodel
    
    private let userDefaults = UserDefaults.standard
    private let configKey = "chatViewConfiguration"
    private var cancellables = Set<AnyCancellable>()
    
    private let apiClient = APIClient()

    init() {
        if let data = userDefaults.data(forKey: configKey),
           let savedConfig = try? JSONDecoder().decode(ChatViewConfigurationmodel.self, from: data) {
            config = savedConfig
        } else {
            config = ChatViewConfigurationmodel()
        }
        
        // Observe changes to config and save them
        $config
              .debounce(for: 0.5, scheduler: RunLoop.main)
              .sink { [weak self] _ in self?.saveConfiguration() }
              .store(in: &cancellables)
    }

    func translateText() {
            guard !inputText.isEmpty else { return }
            isLoading = true
            
            let request = QuestionRequest(prompt: inputText)
            
            guard let requestData = try? JSONEncoder().encode(request) else {
                isLoading = false
                outputText = "Failed to encode the request"
                return
            }

            apiClient.postData(to: "translate", body: requestData) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    switch result {
                    case .success(let data):
                        if let response = try? JSONDecoder().decode(QuestionResponse.self, from: data) {
                            self?.outputText = response.answer
                        } else {
                            self?.outputText = "Failed to decode the response"
                        }
                    case .failure(let error):
                        self?.outputText = "Error: \(error.localizedDescription)"
                    }
                }
            }
        }
    func saveConfiguration() {
        if let data = try? JSONEncoder().encode(config) {
            userDefaults.set(data, forKey: configKey)
        }
    }

    func pasteClipboard() {
        if let clipboardContents = NSPasteboard.general.string(forType: .string) {
            inputText = clipboardContents
        }
    }

    func copyToClipboard() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(outputText, forType: .string)
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
}

struct ChatRequest: Codable {
    let text: String
    let summarize: Bool
}
