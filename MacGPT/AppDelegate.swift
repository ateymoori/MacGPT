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
        
        registerHotkey()
        requestScreenRecordingPermission()
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
    
    
    
//    screenshot
    func promptForSaveLocation() -> URL? {
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["jpg"]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "screenshot.jpg"

        let response = savePanel.runModal()
        return response == .OK ? savePanel.url : nil
    }

    func takeScreenshot() {
        guard let saveURL = promptForSaveLocation() else { return }

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", saveURL.path]
        task.launch()
    }
    private func requestScreenRecordingPermission() {
         // Use CGWindowListCreateImage to trigger the permission dialog
         CGWindowListCreateImage(CGRect.null, .optionAll, kCGNullWindowID, .nominalResolution)
     }
    func hotkeyHandler(eventHandlerCallRef: EventHandlerCallRef?, eventRef: EventRef?, userData: UnsafeMutableRawPointer?) -> OSStatus {
        // Assuming AppDelegate is userData, cast it and call your screenshot function
        let appDelegate = Unmanaged<AppDelegate>.fromOpaque(userData!).takeUnretainedValue()
        appDelegate.takeScreenshot()
        return noErr
    }

    private func registerHotkey() {
        let signature = UTGetOSTypeFromString("Cmd5" as CFString)
        var hotKeyID = EventHotKeyID(signature: signature, id: UInt32(1))
        
        let registerResult = RegisterEventHotKey(UInt32(kVK_ANSI_5), UInt32(cmdKey), hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        if registerResult != noErr {
            NSLog("Failed to register hotkey with error: \(registerResult)")
        }
    }



}
