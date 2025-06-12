//
//  CodeView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/8/25.
//

import Elb
import SwiftUI

extension GeometryProxy {
    fileprivate func exlusion(in space: some CoordinateSpaceProtocol) -> CGRect {
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
    
    func calculateNumberLabel() -> CGFloat {
        let chars: CGSize = "\(lineHeights.count * 10)".size(withAttributes: [.font: OSMonoFont])
        return chars.width
    }
    
    var responses: some View {
        let numberWidth = self.calculateNumberLabel()
        
        return VStack(spacing: 0) {
            ForEach(lineHeights.indices, id: \.self) { line in
                let height = self.getLineHeight(at: line)
                HStack {
                    Text("\(line + 1)")
                        .frame(width: numberWidth, height: height, alignment: .topTrailing)
                        .font(Font(OSMonoFont))
#if OUTLINES
                        .border(Color.green, width: 1)
#endif
                    Spacer()
                }
                .frame(height: height)
#if OUTLINES
                .border(Color.blue, width: 1)
#endif
                if let message = messages[line + 1] {
                    message.overlay(alignment: .center) {
                        GeometryReader { proxy in
                            Color.clear.onChange(of: proxy.exlusion(in: space), initial: true) {
                                (_, new) in
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
    }
    
    var body: some View {
        // Add the padding we want
        let gutterWidth = self.calculateNumberLabel() + 4
        
        ScrollView([.vertical]) {
            ZStack(alignment: .topLeading) {
                CodeTextView(
                    text: $text,
                    lineHeight: $lineHeights,
                    exclusionPaths: exclusionPaths,
                ).padding(.leading, gutterWidth)
                self.responses
            }.coordinateSpace(space)
        }
        .background(
            ZStack {
#if os(macOS)
                Color(NSColor.textBackgroundColor)
#else
                Color.init(UIColor.systemBackground)
#endif
                HStack {
                    Color.clear.frame(width: gutterWidth).background(.regularMaterial)
                    Color.clear
                }
            }
        )
        .defaultScrollAnchor(.top)
        .scrollDismissesKeyboard(.interactively)
    }
    
    private func getLineHeight(at index: Int) -> CGFloat {
        if self.lineHeights.count > index && self.lineHeights[index] > 0 {
            return self.lineHeights[index]
        }
        return 0
    }
}

#Preview {
    CodeView(
        text: .constant("count \"Hello World\"\nprint (2 * 100)\n"),
        messages: .constant([
            1: ResultGroup(results: [
                Response(
                    line: 1,
                    status: .value,
                    output: "1234 alskdjasd aslkjdasd asldkjasdlkj asldkjasd lajsd\n",
                ),
                Response(
                    line: 1,
                    status: .info,
                    output: "Info that gets printed",
                ),
                Response(
                    line: 1,
                    status: .error,
                    output: "This is an error output"
                )
            ]),
            2: ResultGroup(results: [
                Response(
                    line: 1,
                    status: .eof,
                )
            ])
        ])
    )
}
