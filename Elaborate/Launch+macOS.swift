//
//  Launch+macOS.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/24/25.
//

#if os(macOS) || targetEnvironment(macCatalyst)
import SwiftUI

struct LaunchScene: Scene {
    var body: some Scene {
        DocumentGroup(newDocument: ElaborateDocument()) { file in
            let content = ContentView(document: file.$document)
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
#endif
