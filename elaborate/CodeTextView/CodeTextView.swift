//
//  CodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI

public struct CodeTextView {
    static let fontSize: CGFloat = {
#if os(macOS)
        return NSFont.systemFontSize(for: .regular)
#elseif os(iOS) || targetEnvironment(macCatalyst)
        return UIFont.preferredFont(forTextStyle: .body).pointSize
#endif
    }()

    public var text: Binding<String>
    public var lineHeight: Binding<[CGFloat]>?
    public var exclusionPaths: [CGRect]

    public init(text: Binding<String>, lineHeight: Binding<[CGFloat]>? = nil, exclusionPaths: [CGRect] = []) {
        self.text = text
        self.lineHeight = lineHeight
        self.exclusionPaths = exclusionPaths
    }
}

#Preview {
    @Previewable @State var text: String = ") help"
    CodeTextView(text: $text)
}
