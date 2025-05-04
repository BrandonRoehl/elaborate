//
//  NSCodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(macOS)
import SwiftUI
import AppKit

extension CodeView: NSViewRepresentable {
    public typealias Coordinator = CVCoordinator
    
    @MainActor public func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView(
            frame: CGRect(),
            textContainer: context.coordinator.textContainer
        )
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width, .height]
//        textView.backgroundColor = .clear
        return textView
    }
    
    @MainActor public func updateNSView(_ textView: NSTextView, context: Context) {
//        let ranges = textView.selectedRanges
//        defer { textView.selectedRanges = ranges }
        context.coordinator.update(self)
//        scrollView.setNeedsDisplay(scrollView.bounds)
    }
    
    @MainActor public func sizeThatFits(_ proposal: ProposedViewSize, nsView textView: NSTextView, context: Context) -> CGSize? {
        guard
            let container = textView.textContainer,
            let layout = textView.layoutManager,
            let width = proposal.width,
            width > 0
        else {
            return nil
        }
        container.containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        layout.ensureLayout(for: container)
        let usedRect = layout.usedRect(for: container)
        let newSize = proposal.replacingUnspecifiedDimensions(by: usedRect.size)
        return newSize
    }
}
#endif
