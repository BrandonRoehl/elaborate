//
//  NSCodeView.swift
//  Elaborate
//
//  Created by Brandon Roehl on 6/6/25.
//

#if os(macOS)

import SwiftUI
import AppKit

/// A text view whose copy/cut emits the plain source text on the pasteboard.
/// Message attachments (U+FFFC) are dropped; the real newlines that follow
/// them are kept, so the copy still has its linebreaks.
final class ElaborateTextView: NSTextView {
    override func copy(_ sender: Any?) {
        let range = self.selectedRange
        guard range.length > 0 else {
            return super.copy(sender)
        }
        let selection = (self.string as NSString).substring(with: range)
        let clean = selection.replacingOccurrences(of: "\u{FFFC}", with: "")
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(clean, forType: .string)
    }
    
    override func cut(_ sender: Any?) {
        let range = self.selectedRange
        guard range.length > 0 else {
            return super.cut(sender)
        }
        self.copy(sender)
        self.replaceCharacters(in: range, with: "")
    }
}

extension CodeTextView: NSViewRepresentable {
    
    public func makeNSView(context: Context) -> NSTextView {
        let textView = ElaborateTextView(frame: CGRect(), textContainer: context.coordinator.textContainer)
        textView.allowsUndo = true
        textView.isHorizontallyResizable = false
        textView.isRichText = false
        textView.isVerticallyResizable = false
        textView.autoresizingMask = [.height]
        textView.font = context.coordinator.OSMonoFont
        textView.backgroundColor = .clear
        return textView
    }
    
    public func updateNSView(_ textView: NSTextView, context: Context) {
        context.coordinator.update(self)
    }
    
    @MainActor public func sizeThatFits(_ proposal: ProposedViewSize, nsView textView: NSTextView, context: Context) -> CGSize? {
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
