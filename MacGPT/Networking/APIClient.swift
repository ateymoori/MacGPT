//
//  APIClient.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation
 
class APIClient: NetworkServiceProtocol {
    
    private let baseURL = URL(string: "https://amirteymoori.com/translator/public/api/")!

    
    func fetchData(from endpoint: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        getRequestHeaders().forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        logRequest(request)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.logError(error)
                completion(.failure(.failedRequest(description: error.localizedDescription)))
                return
            }
            
            self.logResponse(data, response: response as? HTTPURLResponse)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    func postData(to endpoint: String, body: Data?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        
        getRequestHeaders().forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        logRequest(request)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.logError(error)
                completion(.failure(.failedRequest(description: error.localizedDescription)))
                return
            }
            
            self.logResponse(data, response: response as? HTTPURLResponse)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            completion(.success(data))
        }
        task.resume()
    }
    
    // Logging methods
    private func logRequest(_ request: URLRequest) {
        print("Request URL: \(request.url?.absoluteString ?? "Unknown URL")")
        print("Method: \(request.httpMethod ?? "Unknown Method")")
        logHeaders(request.allHTTPHeaderFields)
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }
    
    private func logResponse(_ data: Data?, response: HTTPURLResponse?) {
        print("Response URL: \(response?.url?.absoluteString ?? "Unknown URL")")
        print("Status Code: \(response?.statusCode ?? 0)")
        if let data = data,
           let responseString = String(data: data, encoding: .utf8) {
            print("Response Body: \(responseString)")
        }
    }
    
    private func logError(_ error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    
    private func logHeaders(_ headers: [String: String]?) {
        print("Headers: ")
        headers?.forEach { key, value in
            print("\t\(key): \(value)")
        }
    }
    
    private func getRequestHeaders() -> [String: String] {
        [
            "Content-Type": "application/json",
            "OS-Version": ProcessInfo.processInfo.operatingSystemVersionString,
            "Device-Info": getChipType(),
            "App-Version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
            "Install-ID": KeychainService.shared.getOrCreateCustomerId()
        ]
    }
    
    private func getChipType() -> String {
        var sysInfo = utsname()
        uname(&sysInfo)

        let modelCode: String = withUnsafePointer(to: &sysInfo.machine) {
           $0.withMemoryRebound(to: CChar.self, capacity: 32) {
               ptr in String(cString: ptr)
           }
        }
        return modelCode
 
      }
}


extension APIClient {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: data)
    }
    
    func encode<T: Encodable>(_ object: T) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(object)
    }
}

