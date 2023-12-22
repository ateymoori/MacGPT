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
}

struct ChatRequest: Codable {
    let text: String
    let summarize: Bool
}
