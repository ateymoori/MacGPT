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
           
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(.failedRequest(description: error.localizedDescription)))
                   return
               }
               
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
       
       func postData(to endpoint: String, body: Data, completion: @escaping (Result<Data, NetworkError>) -> Void) {
           let url = baseURL.appendingPathComponent(endpoint)
           var request = URLRequest(url: url)
           request.httpMethod = "POST"
           request.httpBody = body
           
           getRequestHeaders().forEach { request.addValue($1, forHTTPHeaderField: $0) }
           
           let task = URLSession.shared.dataTask(with: request) { data, response, error in
               if let error = error {
                   completion(.failure(.failedRequest(description: error.localizedDescription)))
                   return
               }
               
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
    
    
    private func getRequestHeaders() -> [String: String] {
        [
            "Content-Type": "application/json",
            "OS-Version": ProcessInfo.processInfo.operatingSystemVersionString,
            "Device-Info": getDeviceModel(),
            "App-Version": Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown",
            "Install-ID": KeychainService.shared.getOrCreateCustomerId()
        ]
    }
    
    private func getDeviceModel() -> String {
        var size = 0
        sysctlbyname("hw.model", nil, &size, nil, 0)
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("hw.model", &machine, &size, nil, 0)
        return String(cString: machine)
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

