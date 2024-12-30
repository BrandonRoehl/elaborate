//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI
import Elb
import os

struct ContentView: View {
    static let logger = Logger(subsystem: "elb", category: "content")

    @Binding var document: ElaborateDocument
    @State var results: [Elaborate_Result] = []
    @State var running: Bool = false
    @FocusState private var focused: Bool
    
    @State var task: Task<Void, Never>? = nil
    let font = Font.system(.body).monospaced()
    
    var body: some View {
        VStack {
            TextEditor(text: $document.text)
                .font(font)
                .focused($focused)
            List($results) { result in
                ResultView(result: result)
            }
        }
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
        focused = false
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

//        VSplitView {
//            ScrollView {
//                HStack {
//                    VStack {
//                        let lines = document.text.count(where: \.isNewline) + 1
//                        ForEach(1...lines, id: \.self) { i in
//                            Text(" \(i): ").font(font)
//                        }
//                    }.frame(alignment: .leading).border(.secondary)
//                        .writingToolsBehavior(.disabled)
//                        .textEditorStyle(.plain)
//                        .frame(maxWidth: .infinity)
//                }
//            }.frame(maxWidth: .infinity)
//            ScrollView {
//                Text(document.text).font(font).frame(maxWidth: .infinity)
//            }.frame(maxWidth: .infinity)
//        }


#Preview {
    ContentView(document: .constant(ElaborateDocument()))
}
