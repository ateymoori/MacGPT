//
//  AppDelegate.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Cocoa
import SwiftUI
import Carbon.HIToolbox
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    private enum Constants {
        static let popoverSize = NSSize(width: 500, height: 400)
        static let statusBarIconName = "icon"
        static let hotkeyId = 1
        static let hotkeyKey = UInt32(kVK_ANSI_6)
        static let hotkeyModifiers = UInt32(shiftKey | cmdKey)
    }
    
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var sharedTextModel = SharedTextModel.shared
    private var pinStatusObserver: AnyCancellable?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        configurePopover()
        configureStatusBarItem()
        registerServicesAndHotkeys()
        observePinStatus()
    }
    
    private func configurePopover() {
        popover = NSPopover()
        popover.contentSize = Constants.popoverSize
        popover.behavior = .applicationDefined // Change to make the popover non-transient
        popover.contentViewController = NSHostingController(rootView: ChatView().environmentObject(sharedTextModel))
    }
    
    private func configureStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusBarButton(statusBarItem.button)
    }
    
    private func registerServicesAndHotkeys() {
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
        PermissionsService.shared.requestScreenRecordingPermission()
        registerHotkey()
    }
    
    private func registerHotkey() {
        HotkeysService.shared.registerHotkey(with: (key: UInt32(Constants.hotkeyKey), modifiers: UInt32(Constants.hotkeyModifiers)), id: 1) {
            self.handleHotkeyPress()
        }
    }
    
    private func handleHotkeyPress() {
        ScreenshotService.shared.takeScreenshot { [weak self] url in
            guard let self = self, let screenshotURL = url else { return }
            self.performOCR(on: screenshotURL)
        }
    }
    
    private func performOCR(on url: URL) {
        OCRService.shared.performOCR(on: url) { [weak self] text in
            guard let self = self, let recognizedText = text else { return }
            self.copyTextToClipboard(text: recognizedText)
        }
    }
    
    private func copyTextToClipboard(text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        updateSharedTextModel(with: text)
    }
    
    private func updateSharedTextModel(with text: String) {
        DispatchQueue.main.async {
            self.sharedTextModel.inputText = text
            self.showPopoverIfNeeded()
        }
    }
    
    @objc func processTextService(_ pboard: NSPasteboard, userData: String?, error: UnsafeMutablePointer<NSString>) {
        guard let selectedText = pboard.string(forType: .string) else {
            error.pointee = "No text was found." as NSString
            return
        }
        updateSharedTextModel(with: selectedText)
    }
    
    private func showPopoverIfNeeded() {
        guard let button = statusBarItem.button, !popover.isShown else { return }
        NSApp.activate(ignoringOtherApps: true)
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
    
    private func closePopover(_ sender: AnyObject?) {
        if PinStatus.shared.isPinned {
            popover.performClose(nil)
        }else{
            popover.performClose(sender)
        }
        
    }
    
    private func observePinStatus() {
        pinStatusObserver = PinStatus.shared.$isPinned.sink { [weak self] isPinned in
            self?.updatePopoverBehavior(isPinned: isPinned)
        }
    }
    
    private func updatePopoverBehavior(isPinned: Bool) {
        popover.behavior = isPinned ? .applicationDefined : .transient
    }
    
    @objc func toggleChatPopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover()
        } else {
            showPopoverIfNeeded()
        }
    }
    
    private func closePopover() {
        if !PinStatus.shared.isPinned {
            popover.performClose(nil)
        }
    }
    
    private func configureStatusBarButton(_ button: NSStatusBarButton?) {
        guard let button = button else { return }
        button.image = NSImage(named: Constants.statusBarIconName)
        button.target = self
        button.action = #selector(statusBarButtonClicked(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
    
    
    @objc func statusBarButtonClicked(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            // Right-click: Show context menu
            showContextMenu(for: sender)
        } else {
            // Left-click: Toggle popover
            toggleChatPopover(sender)
        }
    }
    
    private func showContextMenu(for button: NSStatusBarButton) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Menu Item 1", action: #selector(menuItemAction(_:)), keyEquivalent: "").tag = MenuItemAction.menuItem1.rawValue
        menu.addItem(withTitle: "Menu Item 2", action: #selector(menuItemAction(_:)), keyEquivalent: "").tag = MenuItemAction.menuItem2.rawValue
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit", action: #selector(menuItemAction(_:)), keyEquivalent: "q").tag = MenuItemAction.quit.rawValue
        statusBarItem.menu = menu
        statusBarItem.button?.performClick(nil)
        statusBarItem.menu = nil
    }

    @objc func menuItemAction(_ sender: NSMenuItem) {
        guard let action = MenuItemAction(rawValue: sender.tag) else { return }

        switch action {
        case .menuItem1:
            break
        case .menuItem2:
            break
        case .quit:
            NSApp.terminate(self)
        }
    }
    enum MenuItemAction: Int {
        case menuItem1 = 1
        case menuItem2 = 2
        case quit = 99
    }
}

