//
//  UserRequest.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2023-12-26.
//

import Foundation
struct UserRequest: Encodable {
    var userEmail: String?
    var userName: String?
    var userIdentifier: String?

    init(userEmail: String?, userName: String?, userIdentifier: String?) {
        self.userEmail = userEmail
        self.userName = userName
        self.userIdentifier = userIdentifier
    }
}
