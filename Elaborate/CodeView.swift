//
//  CodeView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/8/25.
//

import SwiftUI
import Elb

struct CodeView: View {
    @Binding var text: String
    @Binding var messages: [Int: ResultGroup]

    var body: some View {
        let background = Color(OSColor.textBackgroundColorCompat)

        // The text view scrolls itself, results and line numbers live inside it
        CodeTextView(text: $text, results: messages)
            .background {
                if #available(macOS 26.0, iOS 26.0, *) {
                    background.backgroundExtensionEffect()
                } else {
                    background
                }
            }
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
