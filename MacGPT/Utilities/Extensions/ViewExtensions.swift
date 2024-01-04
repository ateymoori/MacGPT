//
//  ViewExtensions.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//


import Foundation
import SwiftUI
extension View {
    func configureTextEditor() -> some View {
        self
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 170, maxHeight: .infinity)
            .font(.body)
            .padding(4)
            .lineSpacing(5)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "icon_name")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .padding(.trailing, 8)
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Characters count / Limit")
                    }
                    .padding(.trailing, 8)
                }, alignment: .topTrailing
            )
            .border(Color.secondary)
    }
}
