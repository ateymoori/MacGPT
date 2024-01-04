//
//  LanguageListModel.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//

import SwiftUI



class LanguageListModel: ObservableObject {
    @Published var languages: [Language]
    @Published var selectedLanguageCode: String?


    init() {
        languages = LanguageListModel.allLanguages()
        print("LanguageListModel initialized with \(languages.count) languages")

    }

    static func allLanguages() -> [Language] {
        return [
            Language(id: "US", titleInEnglish: "English", titleInNative: "English", isSelected: false),
            Language(id: "FR", titleInEnglish: "French", titleInNative: "Français", isSelected: false),
            Language(id: "DE", titleInEnglish: "German", titleInNative: "Deutsch", isSelected: true),
            Language(id: "ES", titleInEnglish: "Spanish", titleInNative: "Español", isSelected: false),
            Language(id: "CN", titleInEnglish: "Chinese", titleInNative: "中文", isSelected: false),
        ]
    }

    func selectLanguage(code: String) {
        languages.indices.forEach { languages[$0].isSelected = languages[$0].id == code }
        selectedLanguageCode = code
    }
}
