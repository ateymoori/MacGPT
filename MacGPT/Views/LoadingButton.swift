//
//  LoadingButton.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-08.
//

import SwiftUI
 
struct LoadingButton: View {
    var text: String
    var isLoading: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 26)
        }
        .disabled(isLoading)
        .frame(minWidth: 46, maxWidth: 120)
        .background(isLoading ? AnyView(AnimatedBackground()) : AnyView(Color.blue))
        .cornerRadius(3)
        .contentShape(Rectangle())
    }
}

struct AnimatedBackground: View {
    @State private var isAnimated = false

    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .fill(isAnimated ? Color.blue.opacity(0.5) : Color.blue)
            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: isAnimated)
            .onAppear {
                isAnimated = true
            }
    }
}

