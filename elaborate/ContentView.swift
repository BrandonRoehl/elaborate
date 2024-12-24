//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: ElaborateDocument
    
    let font = Font.system(.body).monospaced()
    
    var body: some View {
        TextEditor(text: $document.text).font(font)
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
        do {
            print("=== Running ===")
            let results = try self.document.execute()
            for result in results {
                if result.status != .success {
                    print(result.line, ":", try result.jsonString())
                } else {
                    print("ERROR:", result.line, ":", try result.jsonString())
                }
            }
        } catch {
            print("Error:", error)
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
