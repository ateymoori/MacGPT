//
//  PermissionsManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-29.
//

import Foundation
import Cocoa

class PermissionsService {
    static let shared = PermissionsService()

    func requestScreenRecordingPermission() {
        // Use CGWindowListCreateImage to trigger the permission dialog
        CGWindowListCreateImage(CGRect.null, .optionAll, kCGNullWindowID, .nominalResolution)
    }
}
