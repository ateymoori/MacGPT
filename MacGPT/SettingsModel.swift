//
//  SettingsModel.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Foundation

class SettingsModel: ObservableObject {
    static let shared = SettingsModel() // Make it a singleton for easy access

    @Published var apiKey: String {
        didSet { saveApiKey() }
    }
    
    @Published var initialPrompt: String {
        didSet { saveInitialPrompt() }
    }
    
    init() {
        apiKey = UserDefaults.standard.string(forKey: "OpenAI_APIKey") ?? ""
        initialPrompt = UserDefaults.standard.string(forKey: "OpenAI_InitPrompt") ?? ""
    }
    
    func saveApiKey() {
        UserDefaults.standard.set(apiKey, forKey: "OpenAI_APIKey")
    }
    
    func saveInitialPrompt() {
        UserDefaults.standard.set(initialPrompt, forKey: "OpenAI_InitPrompt")
    }
}
