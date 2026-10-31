//
//  CodeTextView.swift
//  Elaborate
//
//  Created by Brandon Roehl on 1/8/25.
//

import SwiftUI

/// A single row in the line number gutter.
///
/// Code rows carry their 1-based line number, message rows (the embedded
/// result views) carry no number.
public struct GutterRow: Equatable {
    public var height: CGFloat
    public var line: Int?
    
    public init(height: CGFloat, line: Int? = nil) {
        self.height = height
        self.line = line
    }
}

public struct CodeTextView {
    public var text: Binding<String>
    public var messages: [Int: ResultGroup]
    public var lineHeight: Binding<[GutterRow]>?
    
    public init(text: Binding<String>, messages: [Int: ResultGroup] = [:], lineHeight: Binding<[GutterRow]>? = nil) {
        self.text = text
        self.messages = messages
        self.lineHeight = lineHeight
    }
}

public extension String {
    func size(withAttributes: [NSAttributedString.Key: Any]) -> CGSize {
        return (self as NSString).size(withAttributes: withAttributes)
    }
}

#Preview {
    @State var text = "Hello World"
    return AnyView(
        CodeTextView(text: $text)
            .frame(width: 200)
            .padding()
    )
}
