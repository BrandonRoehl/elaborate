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
    @State var exclusionSizes: [Int: CGRect] = [:]
    
    var exclusionPaths: [CGRect] {
        return messages.keys.compactMap { line in exclusionSizes[line] }
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            CodeTextView(
                text: $text,
                lineHeight: $lineHeights,
                exclusionPaths: exclusionPaths,
            )
            VStack {
                ForEach(lineHeights.indices, id: \.self) { line in
                    Spacer().frame(height: self.getLineHeight(at: line))
                    if let message = messages[line + 1] {
                        message.overlay(alignment: .center) {
                            GeometryReader { proxy in
                                Color.clear.onChange(of: proxy.size.height, initial: true) {
                                    let frame: CGRect = proxy.frame(in: .global)
                                    self.updateExclusionSize(line: line + 1, frame: frame)
                                }
                                #if DEBUG
                                .border(Color.red, width: 4)
                                #endif
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getLineHeight(at index: Int) -> CGFloat {
        if self.lineHeights.count > index && self.lineHeights[index] > 0 {
            return self.lineHeights[index]
        }
        return 0
    }
    
    private func updateExclusionSize(line: Int, frame: CGRect) {
        var frame = frame
        frame.size.width = .infinity
        self.exclusionSizes[line] = frame
    }
}

#Preview {
    CodeView(text: .constant(""), messages: .constant([:]))
}
