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
    
    var body: some View {
        CodeEditor(text: $document.text,
                   position: $editPosition,
                   messages: $messages,
                   language: .swift(),
                   layout: CodeEditor.LayoutConfiguration(showMinimap: true, wrapText: true))
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
                let messages: [TextLocated<Message>] = response.results.compactMap { (result: Elaborate_Result) in
                    let category: Message.Category
                    let summary: String
                    let description: String
                    switch result.status {
                    case .error:
                        category = .error
                        summary = "Error"
                        description = result.output
                    case .value:
                        category = .hole
                        summary = result.output
                        description = ""
                    case .info:
                        category = .informational
                        summary = "Info"
                        description = result.output
                    case .eof, .UNRECOGNIZED(_):
                        return nil
                    }
                    let line = Int(result.line)
                    let location = TextLocation(oneBasedLine: line, column: 1)
                    let entity = Message(
                        category: category,
                        length: 1,
                        summary: summary,
                        description: AttributedString(description)
                    )
                    return TextLocated<Message>(location: location, entity: entity)
                }
                let loc = Set(messages)
                
                await Task { @MainActor in
                    self.messages = loc
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
