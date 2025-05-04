//
//  CodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI

public struct CodeView {
    public var text: Binding<String>
    public var lineHeight: Binding<[CGFloat]>?
    public var exclusionPaths: [NSRect]

    public init(text: Binding<String>, lineHeight: Binding<[CGFloat]>? = nil, exclusionPaths: [NSRect] = []) {
        self.text = text
        self.lineHeight = lineHeight
        self.exclusionPaths = exclusionPaths
    }
}

#Preview {
    @Previewable @State var text: String = "Hello, World!"
    CodeView(text: $text)
}
