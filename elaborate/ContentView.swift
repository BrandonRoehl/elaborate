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
import AsyncAlgorithms


func streamHack<T>(_: T.Type) -> (AsyncStream<T>, AsyncStream<T>.Continuation) {
    var out: AsyncStream<T>.Continuation!
    let stream = AsyncStream<T> { cont in
        out = cont
    }
    return (stream, out)
}

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
    
    let stream = AsyncChannel<ElaborateDocument>()
    
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
            if running {
                ToolbarItem(placement: .primaryAction) {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Help", systemImage: "questionmark.circle") {
                    print("helpme")
                }
            }
        }
        .onAppear {
            self.task = Task.detached(priority: .background) {
                for await doc in stream {
                    print("detect")
                    await run(doc)
                    print("next")
                }
                print("done")
            }
        }
        .onDisappear {
            self.task?.cancel()
            self.stream.finish()
        }
        .onChange(of: self.document.text, initial: true) {
            Task {
                await self.stream.send(self.document)
            }
        }
    }
    
    nonisolated func run(_ document: ElaborateDocument) async {
        await Task { @MainActor in
#if os(iOS)
            editorIsFocused = false
#endif
            running = true
        }.value
        do {
            print("=== Running ===")
            var error: NSError?
            guard let data = ElbExecute(document.text, &error) else {
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
        await Task { @MainActor in
            running = false
        }.value
        print("done")
    }
}

#Preview {
    ContentView(document: .constant(ElaborateDocument()))
}
