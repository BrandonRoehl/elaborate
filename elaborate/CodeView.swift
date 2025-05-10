//
//  CodeView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/8/25.
//

import SwiftUI

fileprivate extension GeometryProxy {
    func exlusion(in space: some CoordinateSpaceProtocol) -> CGRect {
        var frame = self.frame(in: space)
        // Setting both of these makes sure we only call recalculates on a
        // change of line height
        frame.origin.x = 0
        frame.size.width = .infinity
        return frame
    }
}

struct CodeView: View {
    @Binding var text: String
    @Binding var messages: [Int: ResultGroup]
    
    // Internal state to recalculate the offsets
    @State var lineHeights: [CGFloat] = []
    @State var exclusionSizes: [Int: CGRect] = [:]

    let space: NamedCoordinateSpace = .named("codeview")

    var exclusionPaths: [CGRect] {
        return messages.keys.compactMap { line in exclusionSizes[line] }
    }
    
    var gutterWidth: CGFloat {
        return 30
    }
    
    var body: some View {
        ScrollView([.vertical]) {
            ZStack(alignment: .topLeading) {
                CodeTextView(
                    text: $text,
                    lineHeight: $lineHeights,
                    exclusionPaths: exclusionPaths,
                ).padding(.leading, gutterWidth)
                LazyVStack(spacing: 0) {
                    ForEach(lineHeights.indices, id: \.self) { line in
//#if OUTLINES
//                        Rectangle().stroke(Color.blue, lineWidth: 1).frame(height: self.getLineHeight(at: line))
//#else
//                        Spacer().frame(height: self.getLineHeight(at: line))
//#endif
                        HStack {
                            Text("\(line + 1)")
                                .frame(width: self.gutterWidth - 4, height: nil, alignment: .trailing)
                                .font(.system(.body).monospaced())
#if OUTLINES
                                .border(Color.green, width: 1)
#endif
                            Spacer()
                        }
#if OUTLINES
                        .border(Color.blue, width: 1)
#endif
                        if let message = messages[line + 1] {
                            message.overlay(alignment: .center) {
                                GeometryReader { proxy in
                                    Color.clear.onChange(of: proxy.exlusion(in: space), initial: true) { (_, new) in
                                        self.exclusionSizes[line + 1] = new
                                    }
#if OUTLINES
                                    .border(Color.red, width: 1)
#endif
                                }
                            }
                        }
                    }
                }
            }.coordinateSpace(space)
        }.background(
            ZStack {
#if os(macOS)
                Color(NSColor.textBackgroundColor)
#elseif os(iOS) || targetEnvironment(macCatalyst)
                Color.init(UIColor.systemBackground)
#endif
                HStack {
                    Color.clear.frame(width: self.gutterWidth).background(.regularMaterial)
                    Color.clear
                }
            }
        ).defaultScrollAnchor(.top)
    }
    
    private func getLineHeight(at index: Int) -> CGFloat {
        if self.lineHeights.count > index && self.lineHeights[index] > 0 {
            return self.lineHeights[index]
        }
        return 0
    }
}

#Preview {
    CodeView(text: .constant(""), messages: .constant([:]))
}
