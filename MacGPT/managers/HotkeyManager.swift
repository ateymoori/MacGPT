//
//  HotkeyManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-29.
//

import Foundation
import Carbon
import Cocoa

class HotkeyManager {
    static let shared = HotkeyManager()
    private var hotKeyRefs = [UInt32: EventHotKeyRef]()
    private var hotkeyActions = [UInt32: () -> Void]()

    init() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var eventID = EventHotKeyID()
            GetEventParameter(theEvent, UInt32(kEventParamDirectObject), UInt32(typeEventHotKeyID), nil, MemoryLayout.size(ofValue: eventID), nil, &eventID)

            if let action = HotkeyManager.shared.hotkeyActions[eventID.id] {
                NSLog("Hotkey \(eventID.id) pressed") // Logging hotkey press
                action()
                return noErr
            }

            return CallNextEventHandler(nextHandler, theEvent)
        }, 1, &eventType, nil, nil)
    }

    func registerHotkey(with keyCombo: (key: UInt32, modifiers: UInt32), id: UInt32, action: @escaping () -> Void) {
        let hotKeyID = EventHotKeyID(signature: fourCharCode(from: "Hotk\(id)"), id: id)
        var hotKeyRef: EventHotKeyRef?
        let registerResult = RegisterEventHotKey(keyCombo.key, keyCombo.modifiers, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        if registerResult == noErr, let hotKeyRef = hotKeyRef {
            hotKeyRefs[id] = hotKeyRef
            hotkeyActions[id] = action
            NSLog("Hotkey with ID \(id) registered successfully") // Logging successful registration
        } else {
            NSLog("Failed to register hotkey with error: \(registerResult)") // Logging registration failure
        }
    }

    private func fourCharCode(from string: String) -> FourCharCode {
        return string.utf16.reduce(0, {$0 << 8 + FourCharCode($1)})
    }
}
