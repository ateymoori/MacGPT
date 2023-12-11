//
//  OpenAIManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Foundation


class OpenAIManager {
    static let shared = OpenAIManager()

    private let baseURL = "https://api.openai.com/v1/chat/completions"

    private init() {}

    func askQuestion(model: String,prompt: String, systemMessage: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL),
              let apiKey = UserDefaults.standard.string(forKey: "OpenAI_APIKey") else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])))
            return
        }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let payload: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data,
                  let result = try? JSONDecoder().decode(OpenAIChatResponse.self, from: data) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            completion(.success(result.choices.first?.message.content ?? ""))
        }.resume()
    }
}

// Models for the messages and the response
struct OpenAIChatResponse: Decodable {
    let choices: [ChatChoice]
}

struct ChatChoice: Decodable {
    let message: ChatMessage
}

struct ChatMessage: Decodable {
    let role: String
    let content: String
}

