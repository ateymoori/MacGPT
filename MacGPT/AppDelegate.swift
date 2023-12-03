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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 360, height: 360)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ChatView().environmentObject(sharedTextModel))
        
        // Create the status bar item
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusBarItem.button {
            button.image = NSImage(named: "icon") // Ensure this icon exists in your assets
            button.action = #selector(togglePopover(_:))
        }
        
        // Register the service
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
        
        PermissionsManager.shared.requestScreenRecordingPermission()
        
        print("Registering Hotkey")
        HotkeyManager.shared.registerHotkey(with: (key: UInt32(kVK_ANSI_6), modifiers: UInt32(shiftKey | cmdKey)), id: 1) {
            print("Hotkey Cmd+Shift+6")
            
            ScreenshotManager.shared.takeScreenshot { url in
                guard let screenshotURL = url else { return }
                OCRManager.shared.performOCR(on: screenshotURL) { text in
                    guard let recognizedText = text else { return }
                    print(recognizedText)
                    // Do something with the recognized text, e.g., copy to clipboard
                    
                    // Copying to clipboard
                    let pasteboard = NSPasteboard.general
                    pasteboard.clearContents()
                    pasteboard.setString(recognizedText, forType: .string)
                    DispatchQueue.main.async {
                        self.sharedTextModel.inputText = recognizedText
                        self.showPopover()
                    }
                }
            }
            
            
        }
        
        
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                NSApp.activate(ignoringOtherApps: true)
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            }
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
    
    
    
    
    
}
