//
//  CodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI
import SwiftTreeSitterLayer

public struct CodeTextView {
    public var text: Binding<String>
    /// Result views keyed by the (1 based) line they belong to
    var results: [Int: ResultGroup]
    /// Drives syntax highlighting. Everything is `TextColor` when nil.
    let language: LanguageLayer?

    init(text: Binding<String>, results: [Int: ResultGroup] = [:], language: LanguageLayer? = nil) {
        self.text = text
        self.results = results
        self.language = language
    }
}

#Preview {
    @Previewable @State var text: String = ") help"
    CodeTextView(text: $text)
}
