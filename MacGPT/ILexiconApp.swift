//
//  MacGPTApp.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-18.
//
import SwiftUI
import KeyboardShortcuts
 
@main
struct ILexiconApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
 
//    init() {
//          KeyboardShortcuts.onKeyUp(for: .toggleUnicornMode) {
//              // This block is called when the shortcut is pressed.
//              print("Shortcut for Toggle Unicorn Mode was pressed.")
//          }
//      }
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
 
}
