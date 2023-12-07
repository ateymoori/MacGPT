//
//  DraggableWindow.swift
//  MacGPT
//
//  Created by AmirHossein Teymoori on 2023-12-07.
//

import Foundation
import Cocoa

class DraggableWindow: NSWindow {
    private var initialLocation: NSPoint?

    override func mouseDown(with event: NSEvent) {
        initialLocation = event.locationInWindow
    }

    override func mouseDragged(with event: NSEvent) {
        guard let initialLocation = initialLocation else { return }

        let currentLocation = event.locationInWindow
        let deltaX = currentLocation.x - initialLocation.x
        let deltaY = currentLocation.y - initialLocation.y

        var newOrigin = frame.origin
        newOrigin.x += deltaX
        newOrigin.y += deltaY

        setFrameOrigin(newOrigin)
    }
}
