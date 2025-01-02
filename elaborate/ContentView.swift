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
    @State var running: Bool = false

    @Environment(\.colorScheme) private var colorScheme: ColorScheme

    // NB: Writes to a @SceneStorage backed variable are somestimes (always?) not availabe in the update cycle where
    //     the update occurs, but only one cycle later. That can lead to back and forth bouncing values and other
    //     problems in views that take multiple bindings as arguments.
    @State private var editPosition: CodeEditor.Position = .init()
    @SceneStorage("editPosition") private var editPositionStorage: CodeEditor.Position?
    @State private var messages: Set<TextLocated<Message>> = Set()
    @FocusState private var editorIsFocused: Bool

    @State var task: Task<Void, Never>? = nil
    
#if os(iOS)
    let layout: CodeEditor.LayoutConfiguration = .init(showMinimap: false, wrapText: true)
#elseif os(macOS) || os(visionOS)
    let layout: CodeEditor.LayoutConfiguration = .init(showMinimap: true, wrapText: true)
#endif
    
    var body: some View {
        CodeEditor(text: $document.text,
                   position: $editPosition,
                   messages: $messages,
                   language: .elaborate(),
                   layout: layout)
        .focused($editorIsFocused)
        .environment(\.codeEditorTheme, colorScheme == .dark ? Theme.defaultDark : Theme.defaultLight)
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
#if os(iOS)
        editorIsFocused = false
#endif
        running = true
        // Just cancel and start the next
        task?.cancel()
        task = Task.detached(priority: .background) { [text = document.text] in
            do {
                print("=== Running ===")
                var error: NSError?
                guard let data = ElbExecute(text, &error) else {
                    // TODO Throw an actual response
                    return
                }
                if let error {
                    throw error
                }
                // Run the thing
                let messages = try Elaborate_Response(serializedBytes: data).messages
                // Call back to main to update the stuff
                await Task { @MainActor in
                    self.messages = messages
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
