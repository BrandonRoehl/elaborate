//
//  CodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI

public struct CodeTextView {
    public var text: Binding<String>
    /// Result views keyed by the (1 based) line they belong to
    var results: [Int: ResultGroup]

    init(text: Binding<String>, results: [Int: ResultGroup] = [:]) {
        self.text = text
        self.results = results
    }
}

#Preview {
    @Previewable @State var text: String = ") help"
    CodeTextView(text: $text)
}
