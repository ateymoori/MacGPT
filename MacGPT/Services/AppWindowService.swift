//
//  SettingsWindowManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//
import SwiftUI
import AppKit

class AppWindowService {
    static let shared = AppWindowService()
    
    private var settingsWindow: NSWindow?
    private var chatWindow: NSWindow?
    private var reminderWindow: DraggableWindow?
    var chatWindowIsOpen = false
    private let settingsTitle = "iChatGPT Settings"
    private let chatTitle = "iChatGPT Chat"
    private let reminderTitle = "iChatGPT Reminder"
    
    // Function to show Settings Window
    func showSettingsWindow() {
        if settingsWindow == nil {
            settingsWindow = createWindow(with: SettingsView(), title: settingsTitle, width: 500, height: 300)
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        closeOtherWindows(except: settingsWindow)
    }
    
    // Function to show Chat Window
    func showChatWindow() {
        if chatWindow == nil {
            chatWindow = createWindow(with: ChatView(), title: chatTitle, width: 600, height: 400)
        }
        chatWindow?.makeKeyAndOrderFront(nil)
        closeOtherWindows(except: chatWindow)
    }
    
    // Function to show Reminder Window
    func showReminderWindow() {
        DispatchQueue.main.async {
            if self.reminderWindow == nil {
                let contentView = ReminderView()
                self.reminderWindow = DraggableWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 420, height: 400),
                    styleMask: [.resizable, .fullSizeContentView],
                    backing: .buffered, defer: false)
                
                self.configureReminderWindow(with: contentView)
                self.reminderWindow?.isReleasedWhenClosed = false
            }
            
            self.reminderWindow?.makeKeyAndOrderFront(nil)
            self.closeOtherWindows(except: self.reminderWindow)
        }
    }
    
    // Generic function to create a window
    private func createWindow<V: View>(with view: V, title: String, width: CGFloat, height: CGFloat) -> NSWindow {
        let hostingView = NSHostingView(rootView: view)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        window.center()
        window.contentView = hostingView
        window.title = title
        window.isReleasedWhenClosed = false
        return window
    }
    
    // Configure Reminder Window
    private func configureReminderWindow<V: View>(with view: V) {
        reminderWindow?.center()
        reminderWindow?.setFrameAutosaveName("ReminderWindow")
        reminderWindow?.isOpaque = false
        reminderWindow?.backgroundColor = NSColor.black.withAlphaComponent(0.0)
        reminderWindow?.level = .floating
        reminderWindow?.contentView = NSHostingController(rootView: view.frame(maxWidth: .infinity, maxHeight: .infinity)).view

        reminderWindow?.isMovableByWindowBackground = true
        reminderWindow?.contentView?.wantsLayer = true
        reminderWindow?.contentView?.layer?.cornerRadius = 20
        reminderWindow?.contentView?.layer?.masksToBounds = true
        reminderWindow?.collectionBehavior = .canJoinAllSpaces
        reminderWindow?.minSize = NSMakeSize(200, 200)
        reminderWindow?.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
    }
    
    // Function to close other windows except the one passed
    private func closeOtherWindows(except window: NSWindow?) {
        print("Closing other windows...")
        let windowsToClose = ["Settings": settingsWindow, "Chat": chatWindow, "Reminder": reminderWindow]
        windowsToClose.forEach { (key, otherWindow) in
            if otherWindow != window && otherWindow?.isVisible == true {
                print("Closing \(key) window.")
                otherWindow?.close()
            } else {
                print("\(key) window is not visible or is the current window.")
            }
        }
        
        // Close the chat popover if it is open
        if chatWindowIsOpen, window !== chatWindow {
            closeChatPopover()
        }
    }
    
    // Function to close the ChatView popover
    private func closeChatPopover() {
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.toggleChatPopover(nil)
            chatWindowIsOpen = false
        }
    }
    
    var isChatWindowVisible: Bool {
        return chatWindow?.isVisible ?? false
    }
    
    func closeChatWindow() {
        chatWindow?.close()
    }
    
    func closeReminderWindow() {
        DispatchQueue.main.async {
            self.reminderWindow?.close()
        }
    }
    
}
