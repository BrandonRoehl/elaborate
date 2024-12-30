//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI
import os

struct ContentView: View {
    static let logger = Logger(subsystem: "elb", category: "content")

    @Binding var document: ElaborateDocument
    
    let font = Font.system(.body).monospaced()
    
    var body: some View {
        VStack {
            TextEditor(text: $document.text).font(font)
            List($document.results) { result in
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
        }
    }
    
    func run() {
        Task(priority: .background) {
            do {
                print("=== Running ===")
                try self.document.execute()
            } catch {
                Self.logger.error("Error: \(error)")
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
