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

    // Function to check if the drag should start (Example: checking a region)
    private func shouldStartDrag(event: NSEvent) -> Bool {
        // Implement logic to determine if the drag should start
        // For example, check if the mouse down event is in a specific region of the window
        // Return true if drag should start, false otherwise

        // Placeholder logic: Drag starts only if clicked on the top 20 pixels of the window
        let dragAreaHeight: CGFloat = 20
        return NSPointInRect(event.locationInWindow, NSRect(x: 0, y: frame.height - dragAreaHeight, width: frame.width, height: dragAreaHeight))
    }

    override func mouseDown(with event: NSEvent) {
        let location = event.locationInWindow
        initialLocation = location
        dragging = false

        if shouldStartDrag(event: event) {
            dragging = true
        } else {
            super.mouseDown(with: event) // Propagate the event
        }
    }

    override func mouseDragged(with event: NSEvent) {
        if dragging {
            let currentLocation = event.locationInWindow
            let deltaX = currentLocation.x - initialLocation!.x
            let deltaY = currentLocation.y - initialLocation!.y

            var newOrigin = frame.origin
            newOrigin.x += deltaX
            newOrigin.y += deltaY

            setFrameOrigin(newOrigin)
        } else {
            super.mouseDragged(with: event) // Propagate the event
        }
    }

    override func mouseUp(with event: NSEvent) {
        if dragging {
            dragging = false
        } else {
            super.mouseUp(with: event) // Propagate the event
        }
    }
}
