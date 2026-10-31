//
//  UICodeView.swift
//  Elaborate
//
//  Created by Brandon Roehl on 6/6/25.
//

#if !os(macOS)

import SwiftUI
import UIKit

/// A text view whose copy/cut emits the plain source text on the pasteboard.
/// Message attachments (U+FFFC) are dropped; the real newlines that follow
/// them are kept, so the copy still has its linebreaks.
final class ElaborateUITextView: UITextView {
    override func copy(_ sender: Any?) {
        let range = self.selectedRange
        guard range.length > 0 else {
            return super.copy(sender)
        }
        let selection = (self.text as NSString).substring(with: range)
        // Message attachments live on their own line; drop those lines so a
        // copied message line is just the code plus its single linebreak.
        let clean = selection
            .components(separatedBy: "\n")
            .filter { $0.trimmingCharacters(in: .whitespaces) != "\u{FFFC}" }
            .joined(separator: "\n")
        UIPasteboard.general.string = clean
    }
    
    override func cut(_ sender: Any?) {
        self.copy(sender)
        let range = self.selectedRange
        guard range.length > 0 else {
            return
        }
        self.text = (self.text as NSString).replacingCharacters(in: range, with: "") as String
        // Notify the delegate so the bound state reflects the deletion.
        (self.delegate as? UITextViewDelegate)?.textViewDidChange?(self)
    }
}

extension CodeTextView: UIViewRepresentable {
    
    @MainActor public func makeUIView(context: Context) -> UITextView {
        let textView = ElaborateUITextView(frame: .zero, textContainer: context.coordinator.textContainer)
        textView.allowsEditingTextAttributes = false
        textView.font = context.coordinator.OSMonoFont
        textView.backgroundColor = .clear
        textView.isScrollEnabled = false
        return textView
    }
    
    public func updateUIView(_ uiView: UITextView, context: Context) {
        context.coordinator.update(self)
    }
    
    @MainActor public func sizeThatFits(_ proposal: ProposedViewSize, uiView textView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0 else {
            return nil
        }
        let container = context.coordinator.textContainer
        let containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        if containerSize != container.size {
            container.size = containerSize
            context.coordinator.syncHeights()
        }
        let layout = context.coordinator.textLayoutManager
        let usedRect = layout.usageBoundsForTextContainer
        return proposal.replacingUnspecifiedDimensions(by: usedRect.size)
    }
}

#endif
