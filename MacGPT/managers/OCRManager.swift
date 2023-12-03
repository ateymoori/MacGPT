//
//  OCRManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-29.
//

import Foundation
import Vision

class OCRManager {
    static let shared = OCRManager()

    func performOCR(on imageURL: URL, completion: @escaping (String?) -> Void) {
        let requestHandler = VNImageRequestHandler(url: imageURL, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                print("OCR failed: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            completion(recognizedStrings.joined(separator: "\n"))
        }
        try? requestHandler.perform([request])
    }
}
