//
//  Tone.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation

enum Tone: String, Codable, CaseIterable {
    case nuetral = "nuetral"
    case friendly = "friendly"
    case formal = "formal"
    case likeATeacher = "likeAteacher"
    
    
    var displayName: String {
        switch self {
        case .nuetral:
            return "Nuetral"
        case .friendly:
            return "Friendly"
        case .formal:
            return "Formal"
        case .likeATeacher:
            return "Like a Teacher"
        }
    }
}
