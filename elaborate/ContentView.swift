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
                    let json = (try? result.jsonString()) ?? ""
                    switch result.status {
                    case .error:
                        Self.logger.error("\(line): \(json)")
                    case .value, .info:
                        Self.logger.info("\(line): \(json)")
                    case .eof, .UNRECOGNIZED(_):
                        Self.logger.debug("\(line): \(json)")
                    }
                }
            }
        }
    }

    @State var task: Task<Void, Never>? = nil
    @State var stream = AsyncChannel<ElaborateDocument>()
    
    var body: some View {
        ScrollView([.vertical]) {
            CodeView(
                text: $document.text,
                messages: $messages,
            )
        }
        .background(
            ZStack {
#if os(macOS)
                Color(NSColor.textBackgroundColor)
#elseif os(iOS) || targetEnvironment(macCatalyst)
                Color.init(UIColor.systemBackground)
#endif
                HStack {
                    Color.clear.frame(width: 30).background(.regularMaterial)
                    Color.clear
                }
            }
        )
        .defaultScrollAnchor(.top)
        .scrollDismissesKeyboard(.interactively)
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
                let stream = await self.stream.debounce(for: .milliseconds(500))
                for await doc in stream {
                    await Self.logger.debug("Running")
                    await run(doc)
                    await Self.logger.debug("Ran")
                }
                await Self.logger.info("Closing task")
            }
        }
        .onDisappear {
            self.task?.cancel()
            self.stream.finish()
        }
        .onChange(of: self.document.text, initial: true) {
            Task.detached(priority: .background) {
                await Self.logger.debug("Sending")
                await self.stream.send(self.document)
                await Self.logger.debug("Sent")
            }
        }
    }
    
    nonisolated func run(_ document: borrowing ElaborateDocument) async {
        await Task.detached(priority: .high) { @MainActor in
            running = true
        }.value
        await withTaskGroup(of: Void.self) { taskGroup in
            do {
                var error: NSError?
                guard let data = ElbExecute(document.text, &error) else {
                    // TODO Throw an actual response
                    return
                }
                if let error {
                    throw error
                }
                // Run the thing
                let responses = try Elaborate_Response(serializedBytes: data).results
                let messages = Dictionary(grouping: responses) { result in
                    Int(clamping: result.line)
                }.mapValues(ResultGroup.init(results:))
                // Call back to main to update the stuff
                taskGroup.addTask(priority: .high) { @MainActor in
                    self.messages = messages
                }
            } catch {
                await Self.logger.error("Error: \(error)")
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
