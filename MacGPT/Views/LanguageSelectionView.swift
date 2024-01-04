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
        HStack {
            Text("To Language : ")
                .fontWeight(.semibold)
            
            Button(action: { showingCustomDialog = true }) {
                languageDisplay
                Spacer()
                Image(systemName: "chevron.down")
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .sheet(isPresented: $showingCustomDialog) {
            CustomDialogView(languageList: languageList, showingDialog: $showingCustomDialog, selectedLanguage: $selectedLanguage)
        }
    }

    private var languageDisplay: some View {
        Group {
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
        }
    }

    private var selectedLanguageTitle: String {
        selectedLanguage.map { "\($0.titleInEnglish) - (\($0.titleInNative))" } ?? "Select Language"
    }
}

struct CustomDialogView: View {
    @ObservedObject var languageList: LanguageListModel
    @Binding var showingDialog: Bool
    @Binding var selectedLanguage: Language?
    @State private var searchText = ""

    var body: some View {
        ZStack {
            Button(action: { showingDialog = false }) {
                Color.clear.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(PlainButtonStyle())
            .zIndex(0)

            VStack {
                searchField
                languageListContainer
            }
            .zIndex(1)
        }
    }

    private var searchField: some View {
        TextField("Search...", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            .overlay(
                HStack {
                    Spacer()
                    Image(systemName: "magnifyingglass").foregroundColor(.gray).padding(.trailing, 24)
                }
            )
    }

    private var languageListContainer: some View {
        List(filteredLanguages, id: \.id) { language in
            languageRow(for: language)
        }
        .frame(width: 330, height: 500)
    }

    private var filteredLanguages: [Language] {
        searchText.isEmpty ? languageList.languages : languageList.languages.filter { language in
            language.titleInEnglish.lowercased().contains(searchText.lowercased()) ||
            language.titleInNative.lowercased().contains(searchText.lowercased()) ||
            language.id.lowercased().contains(searchText.lowercased())
        }
    }

    private func languageRow(for language: Language) -> some View {
        HStack {
            languageImage(for: language)
            Text("\(language.titleInEnglish) - (\(language.titleInNative))").frame(maxWidth: .infinity, alignment: .leading)
            if language.id == selectedLanguage?.id {
                Image(systemName: "checkmark").foregroundColor(.green)
            }
        }
        .frame(height: 30)
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedLanguage = language
                showingDialog = false
            }
        }
    }

    private func languageImage(for language: Language) -> some View {
        Group {
            if let flagImage = language.flag?.originalImage {
                Image(nsImage: flagImage).resizable().scaledToFit().frame(width: 20, height: 15)
            } else {
                language.placeholderFlagImage.resizable().scaledToFit().frame(width: 20, height: 15)
            }
        }
    }
}
