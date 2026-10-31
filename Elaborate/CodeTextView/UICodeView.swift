//
//  UICodeView.swift
//  Elaborate
//
//  Created by Brandon Roehl on 6/6/25.
//

import SwiftUI
import UIKit

/// A text view whose copy/cut replaces message attachments (U+FFFC) with a
/// linebreak on the pasteboard.
final class ElaborateUITextView: UITextView {
    override func copy(_ sender: Any?) {
        let range = self.selectedRange
        guard range.length > 0 else {
            return super.copy(sender)
        }
        let selection = (self.text as NSString).substring(with: range)
        let clean = selection.replacingOccurrences(of: "\u{FFFC}", with: "\n")
        UIPasteboard.general.string = clean
    }
    
    override func cut(_ sender: Any?) {
        self.copy(sender)
        self.deleteSelection()
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
