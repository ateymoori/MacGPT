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
    private var dragging = false

    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        initialLocation = location
        dragging = false
        super.mouseDown(with: event) // Allow the event to propagate
    }

    override func mouseDragged(with event: NSEvent) {
        if let initialLocation = initialLocation, !dragging {
            let currentLocation = event.locationInWindow
            let deltaX = currentLocation.x - initialLocation.x
            let deltaY = currentLocation.y - initialLocation.y

            var newOrigin = frame.origin
            newOrigin.x += deltaX
            newOrigin.y += deltaY

            setFrameOrigin(newOrigin)
            dragging = true
        } else {
            super.mouseDragged(with: event) // Allow the event to propagate
        }
    }

    override func mouseUp(with event: NSEvent) {
        if dragging {
            dragging = false
        } else {
            super.mouseUp(with: event) // Allow the event to propagate
        }
    }
}
