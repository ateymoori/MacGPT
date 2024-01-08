 //  iLexicon
//
//  Created by Amirhossein Teymoori on 2024-01-04.
//
import SwiftUI
import FlagKit


struct LanguageSelectionView: View {
    @ObservedObject var languageList: LanguageListModel
    @State private var showingCustomDialog = false
    @Binding var selectedLanguage: Language?

    var body: some View {
        HStack {
            Text("To Language : ")
                .fontWeight(.semibold)
            
            Button(action: { showingCustomDialog = true }) {
                languageDisplay
                Spacer()
                Image(systemName: "chevron.down")
            }
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
        VStack {
            HStack {
                Spacer()
                Button(action: { showingDialog = false }) {
                    Image(systemName: "xmark.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(PlainButtonStyle()) // This ensures no additional button styling is applied
            }
            .padding(.trailing, 10)
            
            TextField("Search...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            List(filteredLanguages, id: \.id) { language in
                languageRow(for: language)
            }
            .listStyle(PlainListStyle())
        }
        .padding(.top, 10)
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
            if let flagImage = language.flag?.originalImage {
                Image(nsImage: flagImage).resizable().scaledToFit().frame(width: 20, height: 15)
            } else {
                language.placeholderFlagImage.resizable().scaledToFit().frame(width: 20, height: 15)
            }
            Text("\(language.titleInEnglish) - (\(language.titleInNative))").frame(maxWidth: .infinity, alignment: .leading)
            if language.id == selectedLanguage?.id {
                Image(systemName: "checkmark").foregroundColor(.green)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation {
                selectedLanguage = language
                showingDialog = false
            }
        }
    }
}
