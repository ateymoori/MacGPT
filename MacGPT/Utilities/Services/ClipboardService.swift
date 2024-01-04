//
//  ClipboardService.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//

import Foundation
import AppKit

class ClipboardService {
    static let shared = ClipboardService()
    
    func copyToClipboard(text: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
    
    func pasteFromClipboard() -> String? {
        return NSPasteboard.general.string(forType: .string)
    }
}
