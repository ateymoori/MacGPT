//
//  ScreenshotManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-29.
//

import Foundation
import Cocoa

class ScreenshotManager {
    static let shared = ScreenshotManager()

    func takeScreenshot(completion: @escaping (URL?) -> Void) {
        let tempDirectory = NSTemporaryDirectory()
        let fileName = "screenshot.jpg"
        let tempFileURL = URL(fileURLWithPath: tempDirectory).appendingPathComponent(fileName)

        let task = Process()
        task.launchPath = "/usr/sbin/screencapture"
        task.arguments = ["-i", tempFileURL.path]
        task.terminationHandler = { process in
            guard process.terminationStatus == 0 else {
                completion(nil)
                return
            }
            completion(tempFileURL)
        }
        task.launch()
    }
}
