//
//  NetworkServiceProtocol.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation


protocol NetworkServiceProtocol {
    func fetchData(from endpoint: String, completion: @escaping (Result<Data, NetworkError>) -> Void)
    func postData(to endpoint: String, body: Data?, completion: @escaping (Result<Data, NetworkError>) -> Void)
}
