//
//  MacGPTApp.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-18.
//
import SwiftUI

@main
struct MacGPTApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
