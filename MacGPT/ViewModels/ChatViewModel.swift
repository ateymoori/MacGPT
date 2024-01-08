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
    
    @Published var selectedLanguage: Language?
    @Published var languageListModel = LanguageListModel()
    
    
    init() {
        config = UserDefaults.standard.object(ChatViewConfigurationmodel.self, with: configKey) ?? ChatViewConfigurationmodel()
        observeConfigChanges()
        
        if !config.toLanguage.isEmpty {
            selectedLanguage = languageListModel.languages.first { $0.id == config.toLanguage }
        }
        
        if selectedLanguage == nil {
            selectedLanguage = languageListModel.languages.first { $0.id == "EN" }
            config.toLanguage = "EN"
        }
    }
    
    func translateText() {
        guard !inputText.isEmpty else { return }
        isLoading = true
        let request = createQuestionRequest()
        
        apiClient.postData(to: "translate", body: requestData(from: request)) { [weak self] result in
            DispatchQueue.main.async { self?.handleTranslationResult(result) }
        }
    }
    
    func selectLanguage(code: String) {
        languageListModel.selectLanguage(code: code)
        config.toLanguage = code
        saveConfiguration()
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
            toLanguage: selectedLanguage?.titleInEnglish ,
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
        }
    }
    
    func saveConfiguration() {
        userDefaults.setObject(config, forKey: configKey)
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
