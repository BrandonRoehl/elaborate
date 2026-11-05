//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import AsyncAlgorithms
import Elb
import SwiftUI
import os

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
                    }
                    .keyboardShortcut("r", modifiers: .command)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .task(priority: .utility) {
            let typing = self.debounce.debounce(for: .milliseconds(500))
            let stream = merge(typing, instant)
            for await doc in stream {
                Self.logger.debug("Running")
                await run(doc)
                Self.logger.debug("Ran")
            }
            Self.logger.info("Closing task")
        }
        .onDisappear {
            self.debounce.finish()
            self.instant.finish()
        }
        .onChange(of: self.document.text, initial: true) {
            // Snapshot on the main actor so the binding is never read off-main
            let snapshot = self.document
            let debounce = self.debounce
            Task(priority: .utility) {
				Self.logger.debug("Sending")
                await debounce.send(snapshot)
				Self.logger.debug("Sent")
            }
        }
    }

    nonisolated func run(_ document: borrowing ElaborateDocument) async {
        await Task.detached(priority: .high) { @MainActor in
            running = true
        }.value
        let text = document.text
        // Run the blocking Go call on its own thread, not the cooperative pool
        let responses = await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                continuation.resume(returning: elbExecute(text))
            }
        }
        await withTaskGroup(of: Void.self) { taskGroup in
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
