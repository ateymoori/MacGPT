//
//  OpenAIManager.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Foundation

class OpenAIManager {
    static let shared = OpenAIManager()

    private init() {}

    func askQuestion(prompt: String, systemMessage: String, completion: @escaping (Result<String, Error>) -> Void) {

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
                    let apiKey = UserDefaults.standard.string(forKey: "OpenAI_APIKey") else {
                  print("Error: API Key not set in UserDefaults")
                  completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key not set"])))
                  return
              }

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        let payload: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": systemMessage],
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: .fragmentsAllowed)

        // Log the request details
        logRequest(request, payload: payload)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Log the response details
            self.logResponse(data: data, response: response, error: error)

            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }

            if let result = try? JSONDecoder().decode(OpenAIChatResponse.self, from: data) {
                completion(.success(result.choices.first?.message.content ?? ""))
            } else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
            }
        }

        task.resume()
    }


    private func logRequest(_ request: URLRequest, payload: [String: Any]) {
        print("Request URL: \(request.url?.absoluteString ?? "Invalid URL")")
        print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        print("Request Payload: \(payload)")
    }

    private func logResponse(data: Data?, response: URLResponse?, error: Error?) {
        if let error = error {
            print("Error: \(error)")
        }

        if let httpResponse = response as? HTTPURLResponse {
            print("Response Status Code: \(httpResponse.statusCode)")
        }

        if let data = data, let body = String(data: data, encoding: .utf8) {
            print("Response Body: \(body)")
        }
    }
    
    func correctText(selectedText: String, completion: @escaping (Result<String, Error>) -> Void) {
        // Replace this mock implementation with the actual API call to OpenAI
        DispatchQueue.global(qos: .userInitiated).async {
            // Simulate network delay
            sleep(1)
            
            // Here you would normally perform the API call to OpenAI and process the response
            // The following is just a placeholder response for demonstration purposes
            let placeholderCorrectedText = "This is a simulated corrected version of the text: \(selectedText)"
            
            // Call completion handler with success on the main thread
            DispatchQueue.main.async {
                completion(.success(placeholderCorrectedText))
            }
        }
    }
}

// Models for the messages and the response
struct Message {
    let role: String
    let content: String
}

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
