//
//  ContentView.swift
//  elaborate
//
//  Created by Brandon Roehl on 12/21/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: elaborateDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(elaborateDocument()))
}
