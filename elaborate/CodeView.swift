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
//            VStack {
                ForEach(messages.keys.sorted(), id: \.self) { line in
                    messages[line]!
                    //                    .offset(x: 0, y: CGFloat((200 * line) + 100))
                }
//            }
        }
    }
}

#Preview {
    CodeView(text: .constant(""), messages: .constant([:]))
}
