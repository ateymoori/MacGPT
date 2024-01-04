//
//  LanguageSelectionView.swift
//  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//
import SwiftUI
import FlagKit

struct LanguageSelectionView: View {
    @ObservedObject var languageList: LanguageListModel
    @State private var showingCustomDialog = false
    @State private var selectedLanguage: Language?
    
    var body: some View {
        Button("Select Language") {
            showingCustomDialog = true
        }
        .background(
            // Close dialog when clicking outside
            EmptyView().sheet(isPresented: $showingCustomDialog) {
                CustomDialogView(languageList: languageList,
                                 showingDialog: $showingCustomDialog,
                                 selectedLanguage: $selectedLanguage)
            }
        )
    }
}

struct CustomDialogView: View {
    @ObservedObject var languageList: LanguageListModel
    @Binding var showingDialog: Bool
    @Binding var selectedLanguage: Language?
    
    var body: some View {
        VStack {
            List(languageList.languages) { language in
                HStack {
                    if let flagImage = language.flag?.originalImage {
                        Image(nsImage: flagImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 15) // Smaller flag images
                    } else {
                        language.placeholderFlagImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 15) // Adjusted size for placeholder
                    }
                    Text("  \(language.titleInEnglish) - (\(language.titleInNative))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if language.id == selectedLanguage?.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .frame(height: 30) // Increased height of each row
                .padding(.vertical, 4) // Increased space between rows
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = language
                    showingDialog = false // Close the dialog upon selection
                }
            }
        }
        .frame(width: 330, height: 500)
        .onAppear {
            if let selectedLanguage = selectedLanguage,
               !languageList.languages.contains(where: { $0.id == selectedLanguage.id }) {
                self.selectedLanguage = nil
            }
        }
        .onTapGesture {
            showingDialog = false // Close the dialog when clicking outside the list
        }
        .interactiveDismissDisabled(true)
    }
}
