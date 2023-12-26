//
//  UserResponse.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-26.
//

import Foundation
struct UserResponse: Codable {
    let premium: Bool
    let totalUsedTokens: Int
    let apiCalls: Int
    let totalCost: Double

    enum CodingKeys: String, CodingKey {
        case premium
        case totalUsedTokens = "total_used_tokens"
        case apiCalls = "api_calls"
        case totalCost = "total_cost"
    }
}
