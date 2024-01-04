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
    @Published var isPremiumUser: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let userDefaults = UserDefaults.standard
    private let configKey = "chatViewConfiguration"
    private let apiClient = APIClient()
    
    init() {
        config = UserDefaults.standard.object(ChatViewConfigurationmodel.self, with: configKey) ?? ChatViewConfigurationmodel()
        observeConfigChanges()
    }
    
    func translateText() {
        guard !inputText.isEmpty else { return }
        isLoading = true
        let request = createQuestionRequest()

        apiClient.postData(to: "translate", body: requestData(from: request)) { [weak self] result in
            DispatchQueue.main.async { self?.handleTranslationResult(result) }
        }
    }

    func getUser() {
        apiClient.postData(to: "user", body: nil) { [weak self] result in
            switch result {
            case .success(let data):
                self?.updateUser(from: data)
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }

    private func observeConfigChanges() {
        $config
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.saveConfiguration() }
            .store(in: &cancellables)
    }

    private func createQuestionRequest() -> QuestionRequest {
        QuestionRequest(
            question: inputText,
            toLanguage: config.translateTo ? config.selectedLanguage : nil,
            translate: config.translateTo,
            correctGrammar: config.correctGrammar,
            correctDictation: config.correctDictation,
            summarize: config.summarizeText,
            tone: config.selectedTone.rawValue
        )
    }

    private func requestData(from request: QuestionRequest) -> Data? {
        try? JSONEncoder().encode(request)
    }

    private func handleTranslationResult(_ result: Result<Data, NetworkError>) {
        isLoading = false
        switch result {
        case .success(let data):
            outputText = decodedOutput(from: data) ?? "Failed to decode the response"
        case .failure(let networkError):
            outputText = "Network Error: \(networkError.localizedDescription)"
        }
    }

    private func decodedOutput(from data: Data) -> String? {
        try? JSONDecoder().decode(QuestionResponse.self, from: data).answer
    }

    private func updateUser(from data: Data) {
        if let userResponse = try? JSONDecoder().decode(UserResponse.self, from: data) {
            isPremiumUser = userResponse.premium
            // Additional actions based on userResponse
        }
    }

    func saveConfiguration() {
        userDefaults.setObject(config, forKey: configKey)
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
            "English (UK) British",
            "English (US) American",
            "English (Australian)",
            "English (Canadian)",
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


extension UserDefaults {
    func object<T: Decodable>(_ type: T.Type, with key: String) -> T? {
        guard let data = self.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    func setObject<T: Encodable>(_ object: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(object) {
            self.set(data, forKey: key)
        }
    }
}
