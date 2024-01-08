//
//  QuestionRequest.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation
 
struct QuestionRequest: Codable {
    let question: String
    let toLanguage: String?
    let correctGrammar: Bool?
    let correctDictation: Bool?
    let summarize: Bool?
    let tone: String?

    enum CodingKeys: String, CodingKey {
        case question
        case toLanguage = "to_language"
        case correctGrammar = "correct_grammar"
        case correctDictation = "correct_dictation"
        case summarize
        case tone
    }
}
