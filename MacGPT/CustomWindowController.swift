//
//  CustomWindowController.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Cocoa

class CustomWindowController: NSWindowController {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var resultLabel: NSTextField!

    override func windowDidLoad() {
        super.windowDidLoad()
        // Additional setup after loading the view.
    }

    @IBAction func buttonClicked(_ sender: NSButton) {
        let inputText = textField.stringValue
        // Perform your API call here and update the resultLabel
        // This is a placeholder for the API call logic
        fetchAPIData(inputText: inputText) { result in
            DispatchQueue.main.async {
                self.resultLabel.stringValue = result
            }
        }
    }

    func fetchAPIData(inputText: String, completion: @escaping (String) -> Void) {
        // Implement the API call logic
        // Upon completion, call the completion handler with the result
        // Example: completion("API Result Here")
    }
}
