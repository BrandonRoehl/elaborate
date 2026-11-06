//
//  CodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI
import SwiftTreeSitter

public struct CodeTextView {
    public var text: Binding<String>
    /// Result views keyed by the (1 based) line they belong to
    var results: [Int: ResultGroup]
    /// Drives syntax highlighting. Everything is `TextColor` when nil.
    let language: LanguageConfiguration?

    /// Renders the line number gutter when true
    let lineNumbers: Bool

    init(text: Binding<String>, results: [Int: ResultGroup] = [:], language: LanguageConfiguration? = nil, lineNumbers: Bool = true) {
        self.text = text
        self.results = results
        self.language = language
        self.lineNumbers = lineNumbers
    }
}

#Preview {
    @Previewable @State var text: String = ") help"
    CodeTextView(text: $text)
}
