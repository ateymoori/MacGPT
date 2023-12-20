import Foundation
import os.log
import Security
import Foundation
import os.log

class OpenAIManager {
    static let shared = OpenAIManager()

    private let baseURL = "https://amirteymoori.com/translator/public/api/translate"
    private let logger = Logger(subsystem: "com.yourapp.OpenAIManager", category: "Networking")

    private init() {}

    func askQuestion(prompt: String, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        guard let url = URL(string: baseURL) else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            logger.error("Error: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }

        var request = URLRequest(url: url)
        configureRequest(&request)
        let payload = ["prompt": prompt]

        executeDataTask(with: request, payload: payload, completion: completion)
    }

    private func configureRequest(_ request: inout URLRequest) {
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        addCustomHeaders(to: &request)
    }

    private func addCustomHeaders(to request: inout URLRequest) {
        let processInfo = ProcessInfo.processInfo
        request.addValue(processInfo.operatingSystemVersionString, forHTTPHeaderField: "OS-Version")
        request.addValue("Mac", forHTTPHeaderField: "Device-Info")
        if let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            request.addValue(appVersion, forHTTPHeaderField: "App-Version")
        }
        request.addValue(getOrCreateCustomerId(), forHTTPHeaderField: "Install-ID")
    }

    private func executeDataTask(with request: URLRequest, payload: [String: Any], completion: @escaping (Result<APIResponse, Error>) -> Void) {
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

    private func handleResponse(_ data: Data?, response: URLResponse?, error: Error?, completion: (Result<APIResponse, Error>) -> Void) {
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

        // Log the raw response data
           if let rawResponse = String(data: data, encoding: .utf8) {
               logger.debug("Raw response data: \(rawResponse)")
           } else {
               logger.error("Failed to convert data to string")
           }
        
        do {
            let result = try JSONDecoder().decode(APIResponse.self, from: data)
            logger.debug("Response received: \(String(describing: result))")
            completion(.success(result))
        } catch DecodingError.dataCorrupted(let context) {
            logger.error("Data corrupted: \(context.debugDescription)")
        } catch DecodingError.keyNotFound(let key, let context) {
            logger.error("Key '\(key.stringValue)' not found: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            logger.error("Type '\(type)' mismatch: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type, let context) {
            logger.error("Value '\(type)' not found: \(context.debugDescription)")
        } catch {
            logger.error("JSON Decoding error: \(error.localizedDescription)")
        }
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
    let question: String
    let answer: String
    let openaiChatId: String
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    let model: String
    let osVersion: String
    let device: String
    let appVersion: String
    let installId: String
    let ip: String
    let country: String
    let city: String
    let updatedAt: String
    let createdAt: String
    let id: Int

    enum CodingKeys: String, CodingKey {
        case question, answer, openaiChatId = "oepnai_chat_id", promptTokens = "prompt_tokens",
             completionTokens = "completion_tokens", totalTokens = "total_tokens", model,
             osVersion = "os_version", device, appVersion = "app_version",
             installId = "install_id", ip, country, city, updatedAt = "updated_at",
             createdAt = "created_at", id
    }
}
