//
//  SettingsWindowManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//
import SwiftUI
import AppKit

class SettingsWindowManager {
    static let shared = SettingsWindowManager()
    private var settingsWindow: NSWindow?

    func showSettingsWindow() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingView = NSHostingView(rootView: settingsView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered, defer: false)
            window.center()
            window.contentView = hostingView
            window.title = "iChatGPT Settings"
            window.isReleasedWhenClosed = false
            window.makeKeyAndOrderFront(nil)
            settingsWindow = window
        } else {
            settingsWindow?.makeKeyAndOrderFront(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
    }

    func closeSettingsWindow() {
        DispatchQueue.main.async {
            self.settingsWindow?.close()
            // Delay the setting to nil to avoid potential access after close
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.settingsWindow = nil
            }
        }
    }
}

