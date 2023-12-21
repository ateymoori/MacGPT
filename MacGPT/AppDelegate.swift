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

    func applicationDidFinishLaunching(_ notification: Notification) {
        configurePopover()
        configureStatusBarItem()
        registerServicesAndHotkeys()
    }

    private func configurePopover() {
        popover = NSPopover()
        popover.contentSize = Constants.popoverSize
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: ChatView().environmentObject(sharedTextModel))
    }

    private func configureStatusBarItem() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        configureStatusBarButton(statusBarItem.button)
    }

    private func configureStatusBarButton(_ button: NSStatusBarButton?) {
        guard let button = button else { return }
        button.image = NSImage(named: Constants.statusBarIconName)
        button.action = #selector(toggleChatPopover(_:))
    }

    private func registerServicesAndHotkeys() {
        NSApp.servicesProvider = self
        NSUpdateDynamicServices()
        PermissionsManager.shared.requestScreenRecordingPermission()
        registerHotkey()
    }

    private func registerHotkey() {
        HotkeyManager.shared.registerHotkey(with: (key: UInt32(Constants.hotkeyKey), modifiers: UInt32(Constants.hotkeyModifiers)), id: 1) {
            self.handleHotkeyPress()
        }
    }

    private func handleHotkeyPress() {
        ScreenshotManager.shared.takeScreenshot { [weak self] url in
            guard let self = self, let screenshotURL = url else { return }
            self.performOCR(on: screenshotURL)
        }
    }

    private func performOCR(on url: URL) {
        OCRManager.shared.performOCR(on: url) { [weak self] text in
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

    @objc func toggleChatPopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            showPopoverIfNeeded()
        }
    }
}

