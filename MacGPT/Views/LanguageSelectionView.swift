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

    var body: some View {
        Picker("Select Language", selection: $languageList.selectedLanguageCode) {
            ForEach(languageList.languages) { language in
                HStack {
                    // Display the flag if available, otherwise use a placeholder
                    if let flagImage = language.flag?.originalImage {
                        Image(nsImage: flagImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 20)
                    } else {
                        language.placeholderFlagImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 20)
                    }
                    Text("\(language.titleInEnglish) (\(language.titleInNative))")
                }
                .tag(language.id)
            }
        }
        .pickerStyle(MenuPickerStyle())
        .onChange(of: languageList.selectedLanguageCode) { newValue in
            if let newCode = newValue {
                languageList.selectLanguage(code: newCode)
            }
        }
    }
}
