//
//  ModelInfoView.swift
//  MacGPT
//
//  Created by Amirhossein Teymoori on 2023-12-03.
//
import SwiftUI

struct ModelInfoView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            VStack(spacing: 3) {
                HStack {
                    Text("Model").bold()
                        .frame(width: 150, alignment: .leading)
                    Text("Price/API Call").bold()
                        .frame(width: 150, alignment: .leading)
                    Text("Power").bold()
                        .frame(width: 50, alignment:  .leading)
                        .lineLimit(1)
                }
                
                Divider()
                
                ModelInfoRow(modelKey: "GPT 4 Turbo", price: "$0.01 / 1K tokens", powerRank: "1")
                ModelInfoRow(modelKey: "GPT 4", price: "$0.03 / 1K tokens", powerRank: "2")
                ModelInfoRow(modelKey: "GPT 3.5 Turbo", price: "$0.0015 / 1K tokens", powerRank: "3")
            
              
            }
            .padding()
            .background(Color.primary.opacity(0))
            .cornerRadius(10)
            .shadow(radius: 5)
            
            Text("Prices are per 1,000 tokens (~750 words). Models are sorted by power.")
                .font(.footnote)
                .padding(.top, 5)
            
            Text("Note: Prices may vary. Refer to OpenAI's official documentation for current pricing.")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 1)
        }
        .frame(maxWidth: 410) // Set the maximum width to 300 pixels
        .padding()
        .background(Color.primary.opacity(0)) // Use a transparent background
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

struct ModelInfoRow: View {
    var modelKey: String
    var price: String
    var powerRank: String
    
    var body: some View {
        HStack {
            Text(modelKey)
                .frame(width: 150, alignment: .leading)
            Text(price)
                .frame(width: 150, alignment: .leading)
            Text(powerRank)
                .frame(width: 50, alignment: .center)
        }
    }
}

struct ModelInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ModelInfoView()
    }
}
