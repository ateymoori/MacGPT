//
//  APIClient.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation
import Alamofire

class APIClient: NetworkServiceProtocol {
    
    private let baseURL = URL(string: "https://amirteymoori.com/translator/public/api/")!
    private let googleCloudAPIKey = "AIzaSyBGdaPQF-TRZ_yRS_3sac_cILepQihKZKU"

    func fetchData(from endpoint: String, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)
        AF.request(url, method: .get, headers: HTTPHeaders(getRequestHeaders())).response { response in
            self.logResponse(response, url: url.absoluteString, method: "GET")
            switch response.result {
            case .success(let data):
                if let httpResponse = response.response, httpResponse.statusCode == 200 {
                    completion(.success(data ?? Data()))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(.failedRequest(description: error.localizedDescription)))
            }
        }
    }

    func postData(to endpoint: String, body: Data?, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let url = baseURL.appendingPathComponent(endpoint)
        var parameters: Parameters = [:]
        if let data = body {
            parameters = (try? JSONSerialization.jsonObject(with: data, options: [])) as? Parameters ?? [:]
        }
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(getRequestHeaders())).response { response in
            self.logResponse(response, url: url.absoluteString, method: "POST", parameters: parameters)
            switch response.result {
            case .success(let data):
                if let httpResponse = response.response, httpResponse.statusCode == 200 {
                    completion(.success(data ?? Data()))
                } else {
                    completion(.failure(.invalidResponse))
                }
            case .failure(let error):
                completion(.failure(.failedRequest(description: error.localizedDescription)))
            }
        }
    }

    func performOCR(withBase64Image base64Image: String, completion: @escaping (Result<(text: String, locale: String), NetworkError>) -> Void) {
            let url = baseURL.appendingPathComponent("ocr") // Endpoint in your Laravel API

            let parameters: [String: Any] = [
                "image": base64Image
            ]
            
            AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: HTTPHeaders(getRequestHeaders())).responseDecodable(of: OCRResponse.self) { response in
                switch response.result {
                case .success(let laravelResponse):
                    let text = laravelResponse.text
                    let locale = laravelResponse.locale
                    completion(.success((text: text, locale: locale)))
                case .failure(let error):
                    completion(.failure(.failedRequest(description: error.localizedDescription)))
                }
            }
        }
    
    private func logResponse(_ response: AFDataResponse<Data?>, url: String, method: String, parameters: Parameters? = nil) {
//        print("###########################################")
//        print("Request URL: \(url)")
//        print("Method: \(method)")
//        print("Headers: \(getRequestHeaders())")
//        if let parameters = parameters {
//            print("Parameters: \(parameters)")
//        }
//        if let statusCode = response.response?.statusCode {
//            print("Status Code: \(statusCode)")
//        }
//        if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
//            print("Response: \(responseString)")
//        }
//        if let error = response.error {
//            print("Error: \(error.localizedDescription)")
//        }
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

struct OCRResponse: Decodable {
    var text: String
    var locale: String
}
