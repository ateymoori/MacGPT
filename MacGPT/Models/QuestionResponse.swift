//
//  QuestionResponse.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-23.
//

import Foundation
 
struct QuestionResponse: Codable {
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
    let thisOrderCost: Double
    let userTotalCost: Double
    let userApiCalls: Int
    let premium: Bool

    enum CodingKeys: String, CodingKey {
        case question, answer, model, country, city, id, premium
        case openaiChatId = "oepnai_chat_id"
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
        case osVersion = "os_version"
        case device
        case appVersion = "app_version"
        case installId = "install_id"
        case ip
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case thisOrderCost = "this_order_cost"
        case userTotalCost = "user_total_cost"
        case userApiCalls = "user_api_calls"
    }
}
