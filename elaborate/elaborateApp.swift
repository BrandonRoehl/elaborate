//
//  ElaborateApp.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/21/24.
//

import SwiftUI

@main
struct ElaborateApp: App {
#if os(iOS)
    @Environment(\.openURL) private var openURL
#endif

    var body: some Scene {
#if os(iOS)
        DocumentGroupLaunchScene("Elaborate") {
            NewDocumentButton("Start Calculating")
            Button("Getting Started") {
                if let url = URL(string: "https://pkg.go.dev/robpike.io/ivy") {
                    openURL(url)
                }
            }
        } background: {
            Color.orange
        }
#endif
        DocumentGroup(newDocument: ElaborateDocument()) { file in
#if os(macOS)
            ContentView(document: file.$document)
#else
            NavigationStack {
                ContentView(document: file.$document)
                    .openURLSheet()
                    .toolbarBackground(Material.bar)
                    .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            }
#endif
        }
    }
}
