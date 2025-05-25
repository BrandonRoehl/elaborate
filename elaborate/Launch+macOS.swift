//
//  Launch+macOS.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/24/25.
//

#if os(macOS)
import SwiftUI

struct LaunchScene: Scene {
    @Environment(\.openURL) private var openURL

    var body: some Scene {
        DocumentGroup(newDocument: ElaborateDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            CommandGroup(replacing: .help) {
                Button("Open Ivy Documentation") {
                    if let url = URL(string: "https://pkg.go.dev/robpike.io/ivy") {
                        openURL(url)
                    }
                }
            }
        }
    }
}
#endif
