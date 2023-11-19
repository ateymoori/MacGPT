//
//  SettingsModel.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Foundation

class SettingsModel: ObservableObject {
    static let shared = SettingsModel() // Singleton for easy access

    @Published var apiKey: String {
        didSet { saveApiKey() }
    }

    @Published var initialPrompt: String {
        didSet { saveInitialPrompt() }
    }

    @Published var firstModeName: String {
        didSet { saveFirstModeName() }
    }

    @Published var firstModePrompt: String {
        didSet { saveFirstModePrompt() }
    }

    @Published var secondModeName: String {
        didSet { saveSecondModeName() }
    }

    @Published var secondModePrompt: String {
        didSet { saveSecondModePrompt() }
    }

    init() {
        apiKey = UserDefaults.standard.string(forKey: "OpenAI_APIKey") ?? ""
        initialPrompt = UserDefaults.standard.string(forKey: "OpenAI_InitPrompt") ?? ""
        firstModeName = UserDefaults.standard.string(forKey: "FirstModeName") ?? ""
        firstModePrompt = UserDefaults.standard.string(forKey: "FirstModePrompt") ?? ""
        secondModeName = UserDefaults.standard.string(forKey: "SecondModeName") ?? ""
        secondModePrompt = UserDefaults.standard.string(forKey: "SecondModePrompt") ?? ""
    }

    func saveApiKey() {
        UserDefaults.standard.set(apiKey, forKey: "OpenAI_APIKey")
    }

    func saveInitialPrompt() {
        UserDefaults.standard.set(initialPrompt, forKey: "OpenAI_InitPrompt")
    }

    func saveFirstModeName() {
        UserDefaults.standard.set(firstModeName, forKey: "FirstModeName")
    }

    func saveFirstModePrompt() {
        UserDefaults.standard.set(firstModePrompt, forKey: "FirstModePrompt")
    }

    func saveSecondModeName() {
        UserDefaults.standard.set(secondModeName, forKey: "SecondModeName")
    }

    func saveSecondModePrompt() {
        UserDefaults.standard.set(secondModePrompt, forKey: "SecondModePrompt")
    }
}
