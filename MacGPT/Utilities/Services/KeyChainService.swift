//
//  KeyChainService.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-12-18.
//

import Security
import Foundation

class KeychainService {
    static let shared = KeychainService()
    private let customerIdKey = "CustomerID"
    
    func save(key: String, data: Data) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    func getOrCreateCustomerId() -> String {
        if let customerIdData = load(key: customerIdKey),
           let customerId = String(data: customerIdData, encoding: .utf8) {
            return customerId
        } else {
            let newCustomerId = UUID().uuidString
            if let data = newCustomerId.data(using: .utf8) {
                let saveSuccessful = save(key: customerIdKey, data: data)
                if !saveSuccessful {
                    return ""
                }
            }
            return newCustomerId
        }
    }
}



