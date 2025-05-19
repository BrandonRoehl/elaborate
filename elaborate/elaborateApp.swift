//
//  ElaborateApp.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/21/24.
//

import SwiftUI

@main
struct ElaborateApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: ElaborateDocument()) { file in
            ContentView(document: file.$document)
                .openURLSheet()
//                .toolbarBackground(Material.bar)
//                .toolbarBackgroundVisibility(.visible, for: .navigationBar, .automatic)
        }
    }
}
