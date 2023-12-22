//
//  Tone.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation
 
enum Tone: String, Codable, CaseIterable {
    case dontChange = "dontChange"
    case friendly = "friendly"
    case formal = "formal"
    case negative = "negative"
    case positive = "positive"

    var displayName: String {
        switch self {
        case .dontChange:
            return "Don't Change"
        case .friendly:
            return "Friendly"
        case .formal:
            return "Formal"
        case .negative:
            return "Negative"
        case .positive:
            return "Positive"
        }
    }
}
