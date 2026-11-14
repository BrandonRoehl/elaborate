//
//  ElaborateApp.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/21/24.
//

import SwiftUI

@main
struct ElaborateApp: App {
    @Environment(\.openURL) private var openURL
    @AppStorage("lineNumbers") private var lineNumbers: Bool = true
    @AppStorage("syntaxHighlight") private var syntaxHighlight: Bool = true

    var body: some Scene {
        LaunchScene()
            .commands {
                CommandGroup(replacing: .help) {
                    Button("Open Ivy Documentation") {
                        if let url = URL(string: "https://pkg.go.dev/robpike.io/ivy") {
                            openURL(url)
                        }
                    }
                }
                CommandGroup(before: .toolbar) {
                    Toggle("Show Line Numbers", isOn: $lineNumbers)
                        .keyboardShortcut("l", modifiers: [.command])
                }
                CommandGroup(after: .toolbar) {
                    Toggle("Highlight Syntax", isOn: $syntaxHighlight)
						.keyboardShortcut("h", modifiers: [.command, .shift])
                }
            }
    }
}
