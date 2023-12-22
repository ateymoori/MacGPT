//
//  NetworkError.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation

enum NetworkError: Error {
    case invalidResponse
    case noData
    case failedRequest(description: String)
}
