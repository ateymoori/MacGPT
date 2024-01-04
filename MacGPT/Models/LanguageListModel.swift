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
            Language(id: "ZA", titleInEnglish: "Afrikaans", titleInNative: "Afrikaans", isSelected: false),
            Language(id: "AL", titleInEnglish: "Albanian", titleInNative: "Shqip", isSelected: false),
            Language(id: "ET", titleInEnglish: "Amharic", titleInNative: "አማርኛ", isSelected: false),
            Language(id: "SA", titleInEnglish: "Arabic", titleInNative: "العربية", isSelected: false),
            Language(id: "AM", titleInEnglish: "Armenian", titleInNative: "Հայերեն", isSelected: false),
            Language(id: "AZ", titleInEnglish: "Azerbaijani", titleInNative: "Azərbaycanca", isSelected: false),
            Language(id: "BY", titleInEnglish: "Belarusian", titleInNative: "Беларуская", isSelected: false),
            Language(id: "BD", titleInEnglish: "Bengali", titleInNative: "বাংলা", isSelected: false),
            Language(id: "BA", titleInEnglish: "Bosnian", titleInNative: "Bosanski", isSelected: false),
            Language(id: "BG", titleInEnglish: "Bulgarian", titleInNative: "Български", isSelected: false),
            Language(id: "Catalan", titleInEnglish: "Catalan", titleInNative: "Català", isSelected: false),
            Language(id: "MW", titleInEnglish: "Chichewa", titleInNative: "Chichewa", isSelected: false),
            Language(id: "CN", titleInEnglish: "Chinese (Simplified)", titleInNative: "简体中文", isSelected: false),
            Language(id: "TW", titleInEnglish: "Chinese (Traditional)", titleInNative: "繁體中文", isSelected: false),
            Language(id: "HR", titleInEnglish: "Croatian", titleInNative: "Hrvatski", isSelected: false),
            Language(id: "CZ", titleInEnglish: "Czech", titleInNative: "Čeština", isSelected: false),
            Language(id: "DK", titleInEnglish: "Danish", titleInNative: "Dansk", isSelected: false),
            Language(id: "NL", titleInEnglish: "Dutch", titleInNative: "Nederlands", isSelected: false),
            Language(id: "GB", titleInEnglish: "English", titleInNative: "English", isSelected: false),
            Language(id: "AO", titleInEnglish: "Esperanto", titleInNative: "Esperanto", isSelected: false),
            Language(id: "EE", titleInEnglish: "Estonian", titleInNative: "Eesti", isSelected: false),
            Language(id: "PH", titleInEnglish: "Filipino", titleInNative: "Filipino", isSelected: false),
            Language(id: "FI", titleInEnglish: "Finnish", titleInNative: "Suomi", isSelected: false),
            Language(id: "FR", titleInEnglish: "French", titleInNative: "Français", isSelected: false),
            Language(id: "ES", titleInEnglish: "Galician", titleInNative: "Galego", isSelected: false),
            Language(id: "GE", titleInEnglish: "Georgian", titleInNative: "ქართული", isSelected: false),
            Language(id: "DE", titleInEnglish: "German", titleInNative: "Deutsch", isSelected: false),
            Language(id: "GR", titleInEnglish: "Greek", titleInNative: "Ελληνικά", isSelected: false),
            Language(id: "HT", titleInEnglish: "Haitian Creole", titleInNative: "Kreyòl Ayisyen", isSelected: false),
            Language(id: "NG", titleInEnglish: "Hausa", titleInNative: "Hausa", isSelected: false),
            Language(id: "IL", titleInEnglish: "Hebrew", titleInNative: "עברית", isSelected: false),
            Language(id: "IN", titleInEnglish: "Hindi", titleInNative: "हिन्दी", isSelected: false),
            Language(id: "HU", titleInEnglish: "Hungarian", titleInNative: "Magyar", isSelected: false),
            Language(id: "IS", titleInEnglish: "Icelandic", titleInNative: "Íslenska", isSelected: false),
            Language(id: "ID", titleInEnglish: "Indonesian", titleInNative: "Bahasa Indonesia", isSelected: false),
            Language(id: "IE", titleInEnglish: "Irish", titleInNative: "Gaeilge", isSelected: false),
            Language(id: "IT", titleInEnglish: "Italian", titleInNative: "Italiano", isSelected: false),
            Language(id: "JP", titleInEnglish: "Japanese", titleInNative: "日本語", isSelected: false),
            Language(id: "KZ", titleInEnglish: "Kazakh", titleInNative: "Қазақша", isSelected: false),
            Language(id: "KH", titleInEnglish: "Khmer", titleInNative: "ភាសាខ្មែរ", isSelected: false),
            Language(id: "KR", titleInEnglish: "Korean", titleInNative: "한국어", isSelected: false),
            Language(id: "Kurdish (Kurmanji)", titleInEnglish: "Kurdî (Kurmancî)", titleInNative: "Kurdî (Kurmancî)", isSelected: false),
            Language(id: "KG", titleInEnglish: "Kyrgyz", titleInNative: "Кыргызча", isSelected: false),
            Language(id: "LA", titleInEnglish: "Lao", titleInNative: "ພາສາລາວ", isSelected: false),
            Language(id: "VA", titleInEnglish: "Latin", titleInNative: "Latine", isSelected: false),
            Language(id: "LV", titleInEnglish: "Latvian", titleInNative: "Latviešu", isSelected: false),
            Language(id: "LT", titleInEnglish: "Lithuanian", titleInNative: "Lietuvių", isSelected: false),
            Language(id: "LU", titleInEnglish: "Luxembourgish", titleInNative: "Lëtzebuergesch", isSelected: false),
            Language(id: "MK", titleInEnglish: "Macedonian", titleInNative: "Македонски", isSelected: false),
            Language(id: "MG", titleInEnglish: "Malagasy", titleInNative: "Malagasy", isSelected: false),
            Language(id: "MY", titleInEnglish: "Malay", titleInNative: "Bahasa Melayu", isSelected: false),
            Language(id: "MT", titleInEnglish: "Maltese", titleInNative: "Malti", isSelected: false),
            Language(id: "NZ", titleInEnglish: "Maori", titleInNative: "Māori", isSelected: false),
            Language(id: "MN", titleInEnglish: "Mongolian", titleInNative: "Монгол", isSelected: false),
            Language(id: "MM", titleInEnglish: "Myanmar (Burmese)", titleInNative: "မြန်မာ", isSelected: false),
            Language(id: "NP", titleInEnglish: "Nepali", titleInNative: "नेपाली", isSelected: false),
            Language(id: "NO", titleInEnglish: "Norwegian", titleInNative: "Norsk", isSelected: false),
            Language(id: "PK", titleInEnglish: "Pashto", titleInNative: "پښتو", isSelected: false),
            Language(id: "IR", titleInEnglish: "Persian", titleInNative: "فارسی", isSelected: false),
            Language(id: "PL", titleInEnglish: "Polish", titleInNative: "Polski", isSelected: false),
            Language(id: "PT", titleInEnglish: "Portuguese", titleInNative: "Português", isSelected: false),
            Language(id: "RO", titleInEnglish: "Romanian", titleInNative: "Română", isSelected: false),
            Language(id: "RU", titleInEnglish: "Russian", titleInNative: "Русский", isSelected: false),
            Language(id: "WS", titleInEnglish: "Samoan", titleInNative: "Gagana Samoa", isSelected: false),
            Language(id: "RS", titleInEnglish: "Serbian", titleInNative: "Српски", isSelected: false),
            Language(id: "LS", titleInEnglish: "Sesotho", titleInNative: "Sesotho", isSelected: false),
            Language(id: "LK", titleInEnglish: "Sinhala", titleInNative: "සිංහල", isSelected: false),
            Language(id: "SK", titleInEnglish: "Slovak", titleInNative: "Slovenčina", isSelected: false),
            Language(id: "SI", titleInEnglish: "Slovenian", titleInNative: "Slovenščina", isSelected: false),
            Language(id: "SO", titleInEnglish: "Somali", titleInNative: "Soomaali", isSelected: false),
            Language(id: "SD", titleInEnglish: "Sudanese", titleInNative: "السودانية", isSelected: false),
            Language(id: "SZ", titleInEnglish: "Swazi", titleInNative: "siSwati", isSelected: false),
            Language(id: "SE", titleInEnglish: "Swedish", titleInNative: "Svenska", isSelected: false),
            Language(id: "CH", titleInEnglish: "Swiss German", titleInNative: "Schwyzerdütsch", isSelected: false),
            Language(id: "SY", titleInEnglish: "Syriac", titleInNative: "ܣܘܪܝܝܐ", isSelected: false),
            Language(id: "TJ", titleInEnglish: "Tajik", titleInNative: "тоҷикӣ", isSelected: false),
            Language(id: "TZ", titleInEnglish: "Tanzanian", titleInNative: "Kiswahili", isSelected: false),
            Language(id: "TH", titleInEnglish: "Thai", titleInNative: "ไทย", isSelected: false),
            Language(id: "TL", titleInEnglish: "Timorese", titleInNative: "Lia-Tetun", isSelected: false),
            Language(id: "TG", titleInEnglish: "Togolese", titleInNative: "Togo", isSelected: false),
            Language(id: "TO", titleInEnglish: "Tongan", titleInNative: "Lea Fakatonga", isSelected: false),
            Language(id: "TT", titleInEnglish: "Trinidadian", titleInNative: "Trinidadian", isSelected: false),
            Language(id: "TN", titleInEnglish: "Tunisian", titleInNative: "تونسي", isSelected: false),
            Language(id: "TR", titleInEnglish: "Turkish", titleInNative: "Türkçe", isSelected: false),
            Language(id: "TM", titleInEnglish: "Turkmen", titleInNative: "Türkmençe", isSelected: false),
            Language(id: "UA", titleInEnglish: "Ukrainian", titleInNative: "Українська", isSelected: false),
            Language(id: "AE", titleInEnglish: "Emirati", titleInNative: "الإماراتية", isSelected: false),
            Language(id: "US", titleInEnglish: "American", titleInNative: "American", isSelected: false),
            Language(id: "UY", titleInEnglish: "Uruguayan", titleInNative: "Uruguayan", isSelected: false),
            Language(id: "UZ", titleInEnglish: "Uzbek", titleInNative: "Oʻzbekcha", isSelected: false),
            Language(id: "VU", titleInEnglish: "Vanuatuan", titleInNative: "Bislama", isSelected: false),
            Language(id: "VE", titleInEnglish: "Venezuelan", titleInNative: "Venezuelan", isSelected: false),
            Language(id: "VN", titleInEnglish: "Vietnamese", titleInNative: "Tiếng Việt", isSelected: false),
            Language(id: "YE", titleInEnglish: "Yemeni", titleInNative: "Yemeni", isSelected: false),
            Language(id: "ZM", titleInEnglish: "Zambian", titleInNative: "Zambian", isSelected: false),
            Language(id: "ZW", titleInEnglish: "Zimbabwean", titleInNative: "Shona", isSelected: false)
        ]
    }

    func selectLanguage(code: String) {
        languages.indices.forEach { languages[$0].isSelected = languages[$0].id == code }
        selectedLanguageCode = code
    }
}
