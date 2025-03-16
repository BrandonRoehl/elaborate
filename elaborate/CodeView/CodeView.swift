//
//  CodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI

public struct CodeView<T> where T: View {
    public typealias Results = [Int: T]

    public var showLineNumbers: Bool = true
    public var font: Font = .system(.body).monospaced()

    @Binding public var text: String
    @Binding public var results: Results

    public init(text: Binding<String>, results: Binding<[Int: T]>) {
        self._text = text
        self._results = results
    }
}

extension CodeView where T == EmptyView {
    public init(text: Binding<String>) {
        self._text = text
        self._results = .constant([:])
    }
}

#Preview {
    @Previewable @State var text: String = "Hello, World!"
    CodeView(text: $text)
}
