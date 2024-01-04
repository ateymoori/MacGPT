//
//  Language.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//
import FlagKit
import SwiftUI

struct Language: Identifiable,Hashable {
    let id: String  // Use the country code as the unique ID
    let titleInEnglish: String
    let titleInNative: String
    var isSelected: Bool

    // Computed property to get the corresponding flag image
    var flag: Flag? {
        Flag(countryCode: id)
    }
    
    // Computed property to get a placeholder flag image
    var placeholderFlagImage: Image {
        Image(systemName: "questionmark.circle")
    }
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance is a requirement of Hashable
    static func ==(lhs: Language, rhs: Language) -> Bool {
        lhs.id == rhs.id
    }
}
