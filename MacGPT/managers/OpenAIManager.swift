import Foundation
import os.log
import Security

import Foundation
import os.log

class OpenAIManager {
    static let shared = OpenAIManager()

    private let baseURL = "https://amirteymoori.com/ollama.php"
    private let logger = Logger(subsystem: "com.yourapp.OpenAIManager", category: "Networking")

    private init() {}

    func askQuestion(model: String, prompt: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            logger.error("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        configureRequest(&request)
        let payload = createPayload(forModel: model, withPrompt: prompt)

        executeDataTask(with: request, payload: payload, completion: completion)
    }

    private func configureRequest(_ request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        addCustomHeaders(to: &request)
    }

    private func createPayload(forModel model: String, withPrompt prompt: String) -> [String: Any] {
        return [
            "model": model,
            "prompt": prompt
        ]
    }

    private func executeDataTask(with request: URLRequest, payload: [String: Any], completion: @escaping (Result<String, Error>) -> Void) {
        do {
            var request = request
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
            logger.debug("Request sent with payload: \(String(describing: payload))")

            URLSession.shared.dataTask(with: request) { data, response, error in
                self.handleResponse(data, response: response, error: error, completion: completion)
            }.resume()
        } catch {
            logger.error("JSON Serialization error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    private func handleResponse(_ data: Data?, response: URLResponse?, error: Error?, completion: (Result<String, Error>) -> Void) {
        if let error = error {
            logger.error("Networking error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        guard let data = data else {
            let error = NSError(domain: "", code: -1, userInfo: nil)
            logger.error("No data received")
            completion(.failure(error))
            return
        }

        do {
            let result = try JSONDecoder().decode(APIResponse.self, from: data)
            logger.debug("Response received: \(String(describing: result))")
            completion(.success(result.response))
        } catch {
            logger.error("JSON Decoding error: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    private func addCustomHeaders(to request: inout URLRequest) {
        let processInfo = ProcessInfo.processInfo
        request.addValue(processInfo.operatingSystemVersionString, forHTTPHeaderField: "OS-Version")
        request.addValue("Mac", forHTTPHeaderField: "Device-Info")
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            request.addValue(appVersion, forHTTPHeaderField: "App-Version")
        }
        request.addValue(getOrCreateCustomerId(), forHTTPHeaderField: "Customer-ID")
    }

    private func getOrCreateCustomerId() -> String {
        let customerIdKey = "CustomerID"
        if let customerIdData = KeychainService.shared.load(key: customerIdKey),
           let customerId = String(data: customerIdData, encoding: .utf8) {
            return customerId
        } else {
            let newCustomerId = UUID().uuidString
            if let data = newCustomerId.data(using: .utf8) {
                let saveSuccessful = KeychainService.shared.save(key: customerIdKey, data: data)
                if !saveSuccessful {
                    logger.error("Failed to save new customer ID to Keychain")
                    return ""
                }
            }
            return newCustomerId
        }
    }
}

// MARK: - Model Definitions

struct APIResponse: Decodable {
    let response: String
    let done: Bool
    let model: String
    let timeTakenSeconds: Double
}
