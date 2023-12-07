//
//  ReminderWindowManager.swift
//  MacGPT
//
//  Created by AmirHossein Teymoori on 2023-12-07.
//

import SwiftUI
import Cocoa

class ReminderWindowManager {
    static let shared = ReminderWindowManager()
    private var reminderWindow: DraggableWindow?

    func showReminderWindow() {
        if reminderWindow == nil {
            let contentView = ReminderView()

            // Initialize the DraggableWindow
            reminderWindow = DraggableWindow(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 400),
                styleMask: [.resizable, .fullSizeContentView],
                backing: .buffered, defer: false)

            reminderWindow?.center()
            reminderWindow?.setFrameAutosaveName("ReminderWindow")
            reminderWindow?.isOpaque = false
            reminderWindow?.backgroundColor = NSColor.black.withAlphaComponent(0.0) // Adjusted transparency to 70%
            reminderWindow?.level = .floating
            reminderWindow?.contentView = NSHostingController(rootView: contentView).view
            reminderWindow?.isMovableByWindowBackground = true

            // Apply corner radius
            reminderWindow?.contentView?.wantsLayer = true
            reminderWindow?.contentView?.layer?.cornerRadius = 20 // Enhanced rounded corners
            reminderWindow?.contentView?.layer?.masksToBounds = true

            // Make the window appear on all Spaces
            reminderWindow?.collectionBehavior = .canJoinAllSpaces

            // Set min and max width for the window
            reminderWindow?.minSize = NSMakeSize(200, 200) // Minimum size the window can be resized to
            reminderWindow?.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude) // Maximum size

            reminderWindow?.makeKeyAndOrderFront(nil)
        } else {
            reminderWindow?.makeKeyAndOrderFront(nil)
        }
    }
}
