//
//  ReminderView.swift .swift
//  MacGPT
//
//  Created by AmirHossein Teymoori on 2023-12-07.
//

import SwiftUI
import AVFoundation
struct ReminderView: View {
    @State private var selectedCategory: String = "Professional Greetings"
    @State private var selectedType: String = "Word"
    
    @State private var phrases: [(String, String)] = []
    @State private var isLoading = false
    
    private let categories = ["Professional Greetings", "Office Vocabulary", "Business Meetings", "Workplace Communication", "Everyday Conversations", "Cultural Expressions", "Emergency and Directions", "Shopping and Transactions", "Expressing Emotions", "Humor and Fun", "Casual Greetings and Farewells"]

    private let types = ["Word", "Phrase"]
    
    init() {
        printAvailableVoices()
     }
    
    private func printAvailableVoices() {
        let availableVoices = AVSpeechSynthesisVoice.speechVoices().filter { $0.language == "sv-SE" }
        print("Available Swedish Voices: \(availableVoices)")
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: closeView) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.white)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(8)
                
                Spacer()
                
                // Picker for selecting type (Words or Phrases)
                Picker("", selection: $selectedType) {
                    ForEach(types, id: \.self) { type in
                        Text(type)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 100)
                .onChange(of: selectedType) {
                    fetchPhrasesFromOpenAI()
                }
                // Picker for selecting a category
                Picker("", selection: $selectedCategory) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 200)
                .onChange(of: selectedCategory) {
                    fetchPhrasesFromOpenAI()
                }
            }
            .padding()
            
            if isLoading {
                ProgressView()
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(phrases, id: \.0) { (swedish, english) in
                        phraseRow(swedish: swedish, english: english)
                    }
                }
            }
            .padding()
        }
        .background(Color.black.opacity(0.75))
        .cornerRadius(10)
        .frame(height: 380)
        .onAppear {
                    fetchPhrasesFromOpenAI() // Fetch phrases when the view appears
                }
    }
    
    func fetchPhrasesFromOpenAI() {
        isLoading = true
        
        let systemMessage = """
            As a language tutor, please assist me in learning Swedish, keeping in mind that I am a beginner and work with Swedes in an office environment. I need to learn practical and commonly used Swedish \(selectedType.lowercased()) that will be helpful in my daily interactions in a Swedish office setting. Provide a JSON array of 10 relevant Swedish \(selectedType.lowercased()) in the category of '\(selectedCategory)', each with its English translation. The format should be as follows:
            [
                {"Swedish": "Swedish-\(selectedType.lowercased())1", "English": "EnglishTranslation1"},
                {"Swedish": "Swedish-\(selectedType.lowercased())2", "English": "EnglishTranslation2"},
                ...
            ]
            """
        
        print(systemMessage)
        
//        OpenAIManager.shared.askQuestion(model: "gpt-3.5-turbo", prompt: selectedCategory, systemMessage: systemMessage) { result in
//            DispatchQueue.main.async {
//                isLoading = false
//                switch result {
//                case .success(let response):
//                    print("API Response: \(response)")
//                    self.phrases = self.parseResponse(response)
//                case .failure(let error):
//                    print("Error calling API: \(error.localizedDescription)")
//                }
//            }
//        }
    }
    
    struct MyPhrasePair: Codable {
        let Swedish: String
        let English: String
    }
    
    private func parseResponse(_ response: String) -> [(String, String)] {
        guard let data = response.data(using: .utf8) else {
            print("Error: Can't convert string to Data")
            return []
        }
        
        do {
            let phrasePairs: [MyPhrasePair] = try JSONDecoder().decode([MyPhrasePair].self, from: data)
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
        utterance.voice = AVSpeechSynthesisVoice(language: "sv-SE")
        
        // Stop previous speech before starting the new one
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }
    
    struct PhrasePair: Codable {
        let Swedish: String
        let English: String
    }
    private func closeView() {
          AppWindowService.shared.closeReminderWindow()
      }
}
