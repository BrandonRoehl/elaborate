//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI
import LanguageSupport
import CodeEditorView
import Elb
import os

struct ContentView: View {
    static let logger = Logger(subsystem: "elb", category: "content")

    @Binding var document: ElaborateDocument
    @State var results: [Elaborate_Result] = []
    @State var running: Bool = false

//    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    // NB: Writes to a @SceneStorage backed variable are somestimes (always?) not availabe in the update cycle where
    //     the update occurs, but only one cycle later. That can lead to back and forth bouncing values and other
    //     problems in views that take multiple bindings as arguments.
    @State private var editPosition: CodeEditor.Position = .init()

    @SceneStorage("editPosition") private var editPositionStorage: CodeEditor.Position?

    @State private var messages:         Set<TextLocated<Message>> = Set ()
    @State private var language:         Language                  = .swift
    @State private var showMessageEntry: Bool                      = false
    @State private var showMinimap:      Bool                      = true
    @State private var wrapText:         Bool                      = true

    @FocusState private var editorIsFocused: Bool

    @State var task: Task<Void, Never>? = nil
    let font = Font.system(.body).monospaced()
    
    var body: some View {
        CodeEditor(text: $document.text,
                   position: $editPosition,
                   messages: $messages,
                   language: language.configuration,
                   layout: CodeEditor.LayoutConfiguration(showMinimap: showMinimap, wrapText: wrapText))
          .focused($editorIsFocused)
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Help", systemImage: "questionmark.circle") {
                    print("helpme")
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Run", systemImage: "play.fill", action: self.run)
            }
            if running {
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                }
            }
        }
    }
    
    func run() {
        editorIsFocused = false
        running = true
        // Just cancel and start the next
        task?.cancel()
        task = Task.detached(priority: .background) { [text = document.text] in
            do {
                print("=== Running ===")
                guard let data = ElbExecute(text) else {
                    // TODO Throw an actual response
                    return
                }
                let response = try Elaborate_Response(serializedBytes: data)
                
                await Task { @MainActor in
                    self.results = response.results
                    self.running = false
                }.value
            } catch {
                await Self.logger.error("Error: \(error)")
            }
        }
    }
}

#Preview {
    ContentView(document: .constant(ElaborateDocument()))
}
