//
//  Launch+macOS.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/24/25.
//

#if os(iOS) && !targetEnvironment(macCatalyst)
import SwiftUI
import SafariServices

struct LaunchScene: Scene {
    @State private var urlToOpen: URL?

    var body: some Scene {
        DocumentGroupLaunchScene("Elaborate") {
            NewDocumentButton("Start Calculating")
            Button("Getting Started") {
                if let url = URL(string: "https://pkg.go.dev/robpike.io/ivy") {
                    urlToOpen = url
                }
            }
            .sheet(item: $urlToOpen, content: SFSafariView.init(url:))
        } background: {
            Color.orange
        }
        DocumentGroup(newDocument: ElaborateDocument()) { file in
            NavigationStack {
                let content = ContentView(document: file.$document)
                    .openURLSheet()
                if let url = file.fileURL {
                    content
                        .navigationDocument(url)
                        .navigationTitle(url.lastPathComponent)
                } else {
                    content
                }
            }
        }
    }
}
#endif
