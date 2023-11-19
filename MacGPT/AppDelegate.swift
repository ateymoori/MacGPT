//
//  AppDelegate.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var sharedTextModel = SharedTextModel.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize the popover
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
