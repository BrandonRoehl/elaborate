//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI
import Elb
import os
import AsyncAlgorithms


struct ContentView: View {
    static let logger = Logger(subsystem: "elb", category: "content")
    
    @Binding var document: ElaborateDocument

    @State var running: Bool = false

    @State private var messages: [Int: ResultGroup] = [:] {
        didSet {
            for (line, view) in self.messages {
                for result in view.results {
                    let msg = result.output ?? ""
                    switch result.status {
                    case .error:
                        Self.logger.error("\(line): \(msg)")
                    case .value, .info:
                        Self.logger.info("\(line): \(msg)")
                    case .eof:
                        Self.logger.debug("\(line): \(msg)")
                    }
                }
            }
        }
    }

    @State var debounce = AsyncChannel<ElaborateDocument>()
    @State var instant = AsyncChannel<ElaborateDocument>()

    var body: some View {
        CodeView(
            text: $document.text,
            messages: $messages,
        )
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if running {
                    ProgressView()
                } else {
                    Button("Run", systemImage: "play.fill") {
                        running = true
                        Task {
                            await self.instant.send(self.document)
                        }
                    }.keyboardShortcut("r", modifiers: .command)
                }
            }
        }
        .task(priority: .background) {
            let typing = self.debounce.debounce(for: .milliseconds(500))
            let stream = merge(typing, instant)
            for await doc in stream {
                Self.logger.debug("Running")
                await run(doc)
                Self.logger.debug("Ran")
            }
            Self.logger.info("Closing task")
        }
        .onChange(of: self.document.text, initial: true) {
            Task.detached(priority: .background) {
                await Self.logger.debug("Sending")
                await self.debounce.send(self.document)
                await Self.logger.debug("Sent")
            }
        }
    }
    
    nonisolated func run(_ document: borrowing ElaborateDocument) async {
        await Task.detached(priority: .high) { @MainActor in
            running = true
        }.value
        await withTaskGroup(of: Void.self) { taskGroup in
            let responses = elbExecute(document.text)
            // Run the thing
            let messages = Dictionary(grouping: responses) { result in
                Int(clamping: result.line)
            }.mapValues(ResultGroup.init(results:))
            // Call back to main to update the stuff
            taskGroup.addTask(priority: .high) { @MainActor in
                self.messages = messages
            }
            taskGroup.addTask(priority: .high) { @MainActor in
                self.running = false
                Self.logger.debug("Done updating the main actor")
            }
            await taskGroup.waitForAll()
        }
    }
}

#Preview {
    ContentView(document: .constant(ElaborateDocument()))
}
