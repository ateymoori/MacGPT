//
//  SharedTextModel.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-11-19.
//

import Combine

class SharedTextModel: ObservableObject {
    static let shared = SharedTextModel()
    @Published var inputText: String = ""
}
