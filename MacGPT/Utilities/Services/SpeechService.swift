//
//  SpeechService.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//

import Foundation
import AVFoundation

class SpeechService {
    static let shared = SpeechService()
    private let speechSynthesizer = AVSpeechSynthesizer()
    
    func speakText(_ text: String, language: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
    
    func detectLanguage(from text: String) -> String {
        let tagger = NSLinguisticTagger(tagSchemes: [.language], options: 0)
        tagger.string = text
        return tagger.dominantLanguage ?? "en-US"
    }
    
}
