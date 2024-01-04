//
//  Language.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//
import FlagKit
import SwiftUI

struct Language: Identifiable, Hashable {
    let id: String   
    let titleInEnglish: String
    let titleInNative: String
    var isSelected: Bool

    var flag: Flag? {
        Flag(countryCode: id)
    }
    
    var placeholderFlagImage: Image {
        Image(systemName: "questionmark.circle")
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func ==(lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }
}
