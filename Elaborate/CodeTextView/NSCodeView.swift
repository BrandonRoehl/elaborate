//
//  NSCodeView.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(macOS)
import SwiftUI
import AppKit

extension CodeTextView: NSViewRepresentable {
    public typealias Coordinator = CVCoordinator
    
    @MainActor public func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView(
            frame: CGRect(),
            textContainer: context.coordinator.textContainer
        )
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.isVerticallyResizable = false
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = []
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        return textView
    }
    
    @MainActor public func updateNSView(_ textView: NSTextView, context: Context) {
        context.coordinator.update(self)
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
        let containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        if containerSize != container.containerSize {
            container.containerSize = containerSize
            Task.detached { @MainActor in
                context.coordinator.syncHeights()
            }
        }
        layout.ensureLayout(for: container)
        let usedRect = layout.usedRect(for: container)
        let newSize = proposal.replacingUnspecifiedDimensions(by: usedRect.size)
        return newSize
    }
}
#endif
