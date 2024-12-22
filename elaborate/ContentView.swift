//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 11/24/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: elaborateDocument
    
    let font = Font.system(.body).monospaced()

    var body: some View {
        VSplitView {
//            ScrollView {
//                HStack {
//                    VStack {
//                        let lines = document.text.count(where: \.isNewline) + 1
//                        ForEach(1...lines, id: \.self) { i in
//                            Text(" \(i): ").font(font)
//                        }
//                    }.frame(alignment: .leading).border(.secondary)

                    TextEditor(text: $document.text).font(font)
//                        .writingToolsBehavior(.disabled)
//                        .textEditorStyle(.plain)
//                        .frame(maxWidth: .infinity)
//                }
//            }.frame(maxWidth: .infinity)
            ScrollView {
                Text(document.text).font(font).frame(maxWidth: .infinity)
            }.frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView(document: .constant(elaborateDocument()))
}
