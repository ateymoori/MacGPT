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
    
    var selectedLanguageDisplay: String {
        selectedLanguage?.titleInEnglish ?? "Select Language"
    }
    var body: some View {
        
        HStack {
            Text("To Language : ")
                .fontWeight(.semibold)
            
            Button(action: {
                showingCustomDialog = true
            }) {
                
                
                if let flagImage = selectedLanguage?.flag?.originalImage {
                    Image(nsImage: flagImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 15)
                } else {
                    selectedLanguage?.placeholderFlagImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 15)
                }
                Text(selectedLanguageTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .sheet(isPresented: $showingCustomDialog) {
            CustomDialogView(languageList: languageList,
                             showingDialog: $showingCustomDialog,
                             selectedLanguage: $selectedLanguage)
        }
    }
    
    
    
    private var selectedLanguageTitle: String {
        if let selectedLanguage = selectedLanguage {
            return "\(selectedLanguage.titleInEnglish) - (\(selectedLanguage.titleInNative))"
        } else {
            return "Select Language"
        }
    }
}

struct CustomDialogView: View {
    @ObservedObject var languageList: LanguageListModel
    @Binding var showingDialog: Bool
    @Binding var selectedLanguage: Language?
    @State private var searchText = ""
    
    var filteredLanguages: [Language] {
        if searchText.isEmpty {
            return languageList.languages
        } else {
            return languageList.languages.filter { language in
                language.titleInEnglish.lowercased().contains(searchText.lowercased()) ||
                language.titleInNative.lowercased().contains(searchText.lowercased()) ||
                language.id.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 24)
                    }
                )
            
            List(filteredLanguages, id: \.id) { language in
                HStack {
                    if let flagImage = language.flag?.originalImage {
                        Image(nsImage: flagImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 15)
                    } else {
                        language.placeholderFlagImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 15)
                    }
                    Text("  \(language.titleInEnglish) - (\(language.titleInNative))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if language.id == selectedLanguage?.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(.green)
                    }
                }
                .frame(height: 30)
                .padding(.vertical, 4)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedLanguage = language
                    showingDialog = false
                }
            }
            .frame(width: 330, height: 500)
        }
        .onAppear {
            if let selectedLanguage = selectedLanguage,
               !languageList.languages.contains(where: { $0.id == selectedLanguage.id }) {
                self.selectedLanguage = nil
            }
        }
    }
}
