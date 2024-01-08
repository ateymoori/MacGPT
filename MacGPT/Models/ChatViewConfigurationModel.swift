//
//  ChatViewConfigurationModel.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation

struct ChatViewConfigurationmodel: Codable {
    var correctDictation: Bool = false
    var correctGrammar: Bool = false
    var selectedTone: Tone = .nuetral
    var toDifferentLanguage: Bool = false
    var toLanguage: String = "English (US) American"
    var summarizeText: Bool = false
}

