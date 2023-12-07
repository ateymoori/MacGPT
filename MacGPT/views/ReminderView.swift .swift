//
//  ReminderView.swift .swift
//  MacGPT
//
//  Created by AmirHossein Teymoori on 2023-12-07.
//

import SwiftUI
 
import AVFoundation


struct ReminderView: View {
    // Extracted data from the CSV file
    let phrases = [
        ("God morgon", "Good morning"),
        ("Hej", "Hello"),
        ("Hej då", "Goodbye"),
        ("Vi ses", "See you"),
        ("Ta hand om dig", "Take care"),
        ("Trevlig helg", "Have a nice weekend"),
        ("Vilken vacker dag", "What a beautiful day"),
        ("God natt", "Good night"),
        ("Tack och hej", "Thanks and bye"),
        ("Vi ses imorgon", "See you tomorrow"),
        ("Ha en bra dag", "Have a good day"),
        ("Lycka till", "Good luck"),
        ("Välkommen", "Welcome"),
        ("Trevligt att träffas", "Nice to meet you"),
        ("Ha det så bra", "Take care (informal)"),
        ("Tack för idag", "Thanks for today"),
        ("Vi hörs", "Talk to you later"),
        ("Ha en trevlig kväll", "Have a nice evening"),
        ("God helg", "Have a good weekend"),
        ("Ha en bra semester", "Have a good vacation")
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { // Increased spacing between lines
                ForEach(phrases, id: \.0) { (swedish, english) in
                    HStack {
                        Button(action: {
                            self.speak(text: swedish)
                        }) {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundColor(.white)
                                .accessibility(label: Text("Speak Swedish"))
                        }
                        Text(swedish)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                        Spacer()
                        Text(english)
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.75)) // 70% transparency
            .cornerRadius(10) // Rounded corners
        }
        .padding(.horizontal) // Padding on the sides if needed
    }
    
    private let speechSynthesizer = AVSpeechSynthesizer()

    // Function to handle speech
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "sv-SE") // Swedish language
        
        // Stop previous speech before starting the new one
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }
}
