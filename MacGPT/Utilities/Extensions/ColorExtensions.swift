//
//  ColorExtensions.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//

import Foundation
import SwiftUI

extension Color {
    static var customGreen: Color {
        let colorScheme = NSApplication.shared.windows.first?.effectiveAppearance.name
        switch colorScheme {
        case .some(NSAppearance.Name.aqua), .some(NSAppearance.Name.vibrantLight):
            // Light mode color
            return Color(red: 0.0, green: 0.7, blue: 0.0)
        case .some(NSAppearance.Name.darkAqua), .some(NSAppearance.Name.vibrantDark):
            // Dark mode color - adjust these values as needed
            return Color(red: 0.3, green: 1.0, blue: 0.3)
        default:
            return Color(red: 0.0, green: 0.7, blue: 0.0)
        }
    }

    static var customOrange: Color {
        let colorScheme = NSApplication.shared.windows.first?.effectiveAppearance.name
        switch colorScheme {
        case .some(NSAppearance.Name.aqua), .some(NSAppearance.Name.vibrantLight):
            // Light mode color
            return Color(red: 1.0, green: 0.55, blue: 0.0)
        case .some(NSAppearance.Name.darkAqua), .some(NSAppearance.Name.vibrantDark):
            // Dark mode color - adjust these values as needed
            return Color(red: 1.0, green: 0.75, blue: 0.3)
        default:
            return Color(red: 1.0, green: 0.55, blue: 0.0)
        }
    }
}
