//
//  CodeView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/8/25.
//

import SwiftUI

struct CodeView: View {
    @Binding var text: String
    @Binding var messages: [Int: ResultGroup]
    
    // Internal state to recalculate the offsets
    @State var lineHeights: [CGFloat] = []
    @State var exclusionPaths: [CGRect] = []
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            CodeTextView(
                text: $text,
                lineHeight: $lineHeights,
                exclusionPaths: exclusionPaths,
            )
            LazyVStack {
                ForEach(lineHeights.indices, id: \.self) { line in
                    Spacer().frame(height: lineHeights[line])
                    if let message = messages[line + 1] {
                        message
                    }
                }
            }
        }
    }
}

#Preview {
    CodeView(text: .constant(""), messages: .constant([:]))
}
