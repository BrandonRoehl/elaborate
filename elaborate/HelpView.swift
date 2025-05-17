//
//  HelpView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/17/25.
//

import SwiftUI
import Elb

struct HelpView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        NavigationStack {
            WKHTMLView(content: ElbGetHelp())
        }
        .navigationTitle("Help")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", role: .cancel, action: {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
}

