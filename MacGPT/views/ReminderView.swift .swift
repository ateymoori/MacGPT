//
//  ReminderView.swift .swift
//  MacGPT
//
//  Created by AmirHossein Teymoori on 2023-12-07.
//

import SwiftUI
import AVFoundation

struct ReminderView: View {
    @State private var userInput: String = ""
    @State private var phrases: [(String, String)] = []

    init() {
         printAvailableVoices()
        self.speak(text : "Amir Amir")
         // Other initialization code if necessary
     }
    private func printAvailableVoices() {
           let availableVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "sv-SE" }
           print("Available Swedish Voices: \(availableVoices)")
       }
    var body: some View {
        VStack {
            
            Rectangle()
                .fill(Color.clear)
                .frame(height: 24)
            
            // TextEditor for user input with styled background
            ZStack(alignment: .topLeading) {
                TextEditor(text: $userInput)
                    .opacity(userInput.isEmpty ? 0.5 : 1)
                    .padding(4)
                    .background(Color.gray.opacity(0.2)) // Grey background
                    .cornerRadius(8)
                    .border(Color.gray, width: 1)
                
                if userInput.isEmpty {
                    Text("Enter your question here")
                        .foregroundColor(.white)
                        .padding(.all, 8)
                        .background(Color.clear)
                }
            }
            .frame(height: 100)
            .foregroundColor(.white) // Set text color to white
            
            // Button to send the question
            Button("Ask ChatGPT") {
                fetchPhrasesFromOpenAI(with: userInput)
            }
            .padding()
            
            // Display the phrases
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(phrases, id: \.0) { (swedish, english) in
                        phraseRow(swedish: swedish, english: english)
                    }
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.75)) // 70% transparency
        .cornerRadius(10) // Rounded corners
        .padding(.horizontal) // Padding on the sides if needed
    }
    
    func fetchPhrasesFromOpenAI(with userQuery: String) {
        let systemMessage = """
        Return a JSON array with 15 common Swedish words related to food along with their English translations. Format the response as follows:
        [
            {"Swedish": "SwedishWord1", "English": "EnglishTranslation1"},
            {"Swedish": "SwedishWord2", "English": "EnglishTranslation2"},
            ...
        ]
        """

        OpenAIManager.shared.askQuestion(model: "gpt-3.5-turbo", prompt: userQuery, systemMessage: systemMessage) { result in
            switch result {
            case .success(let response):
                print("Response: \(response)")
                DispatchQueue.main.async {
                    self.phrases = parseResponse(response)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseResponse(_ response: String) -> [(String, String)] {
        guard let data = response.data(using: .utf8) else {
            print("Error: Can't convert string to Data")
            return []
        }

        do {
            let phrasePairs = try JSONDecoder().decode([PhrasePair].self, from: data)
            return phrasePairs.map { ($0.Swedish, $0.English) }
        } catch {
            print("Error parsing JSON: \(error)")
            return []
        }
    }

    
    // Row view for each phrase
    @ViewBuilder
     private func phraseRow(swedish: String, english: String) -> some View {
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
    
    // Speech synthesizer code
    private let speechSynthesizer = AVSpeechSynthesizer()
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "sv-SE") // Swedish language
        
        // Stop previous speech before starting the new one
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }

    struct PhrasePair: Codable {
        let Swedish: String
        let English: String
    }
    
}
