//
//  CodeView.swift
//  Elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI
import os
import Elb
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct CodeView: View {
    static let logger = Logger(subsystem: "elb", category: "codeview")
    
    @Binding var text: String
    
    @Binding var messages: [Int: ResultGroup]
    
    @State var lineHeights: [GutterRow] = []
    
    func calculateNumberLabel() -> CGFloat {
        let chars: CGSize = "\(lineHeights.count * 10)".size(withAttributes: [.font: OSMonoFont])
        return chars.width
    }
    
    /// The editor background color, per platform.
    private var editorBackground: Color {
        #if os(macOS)
        Color(nsColor: .textBackgroundColor)
        #else
        Color(uiColor: .systemBackground)
        #endif
    }
    
    var responses: some View {
        let numberWidth = self.calculateNumberLabel()
        return VStack(spacing: 0) {
            ForEach(lineHeights.indices, id: \.self) { index in
                let row = self.lineHeights[index]
                HStack {
                    if let line = row.line {
                        Text("\(line)")
                            .frame(width: numberWidth, height: row.height, alignment: .topTrailing)
                            .font(Font(OSMonoFont))
                    } else {
                        Color.clear
                            .frame(width: numberWidth, height: row.height)
                    }
                    Spacer()
                }
                .frame(height: row.height)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .topLeading) {
                self.responses
                    .background(.regularMaterial, in: Rectangle())
                CodeTextView(
                    text: $text,
                    messages: self.messages,
                    lineHeight: $lineHeights,
                )
                    .padding(.leading, self.calculateNumberLabel() + 20)
            }
            .background(self.editorBackground)
        }
    }
}

#Preview {
    @State var messages: [Int: ResultGroup] = [
        1: ResultGroup(results: [
            Response(line: 1, status: .value, output: "100"),
        ]),
        3: ResultGroup(results: [
            Response(line: 3, status: .info, output: "hello"),
            Response(line: 3, status: .value, output: "world"),
        ]),
    ]
    @State var text = """
    a = 100
    print a
    1 + 3
    count "the time of this"
    """
    return AnyView(
        CodeView(text: $text, messages: $messages)
    )
}
