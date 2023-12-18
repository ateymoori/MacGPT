//
//  AppDelegate.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Cocoa
import SwiftUI
import Carbon.HIToolbox


class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var sharedTextModel = SharedTextModel.shared
    var hotKeyRef: EventHotKeyRef?
    let pinStatus = PinStatus()
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize and configure the popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 500, height: 400)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ChatView().environmentObject(sharedTextModel).environmentObject(pinStatus)) // Modify this line

        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(named: "icon") // Ensure this icon exists in your assets
            button.action = #selector(toggleChatPopover(_:))
        }
        
        // Register services, permissions, and hotkeys
        registerServices()
    }

    
    private func registerServices() {
        // Register the service
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
        
        PermissionsManager.shared.requestScreenRecordingPermission()
        
        print("Registering Hotkey")
        HotkeyManager.shared.registerHotkey(with: (key: UInt32(kVK_ANSI_6), modifiers: UInt32(shiftKey | cmdKey)), id: 1) {
            print("Hotkey Cmd+Shift+6")
            // Hotkey functionality
            self.handleHotkeyPress()
        }
    }

    private func handleHotkeyPress() {
        ScreenshotManager.shared.takeScreenshot { url in
            guard let screenshotURL = url else { return }
            OCRManager.shared.performOCR(on: screenshotURL) { text in
                guard let recognizedText = text else { return }
                print(recognizedText)
                // Do something with the recognized text, e.g., copy to clipboard
                self.copyTextToClipboard(text: recognizedText)
            }
        }
    }

    private func copyTextToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        DispatchQueue.main.async {
            self.sharedTextModel.inputText = text
            self.showPopover()
        }
    }

    @objc func processTextService(_ pboard: NSPasteboard, userData: String?, error: UnsafeMutablePointer<NSString>) {
        print("Service 'Check with GPT' invoked")
        guard let selectedText = pboard.string(forType: .string) else {
            print("Error: No text found")
            error.pointee = "No text was found." as NSString
            return
        }
        
        print("Selected Text: \(selectedText)")
        
        DispatchQueue.main.async {
            self.sharedTextModel.inputText = selectedText
            self.showPopover()
        }
    }

    private func showPopover() {
        if let button = statusBarItem.button {
            NSApp.activate(ignoringOtherApps: true)
            if !popover.isShown {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
    
    @objc func toggleChatPopover(_ sender: AnyObject?) {
        if popover.isShown && !pinStatus.isPinned {
           // popover.performClose(sender)
        } else {
            if let button = statusBarItem.button {
                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
        }
    }
}
