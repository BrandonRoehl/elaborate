//
//  CodeView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/8/25.
//

import SwiftUI
import Elb
import SwiftTreeSitter
import TreeSitterIvy
import OSLog

struct CodeView: View {
    @Binding var text: String
    @Binding var messages: [Int: ResultGroup]

    private static let logger = Logger(subsystem: "org.brandonroehl.elaborate", category: "CodeView")

    /// Ivy parser and highlight queries, loaded once from the TreeSitterIvy bundle
    private static let language: LanguageConfiguration? = {
        do {
            return try Ivy.configuration()
        } catch {
            logger.error("failed to load ivy language: \(error)")
            return nil
        }
    }()

    var body: some View {
        CodeTextView(text: $text, results: messages, language: Self.language)
            .ignoresSafeArea(.container)
            .background {
				let background = Color(OSColor.textBackgroundColorCompat)
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
