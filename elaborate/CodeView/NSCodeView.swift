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
    public typealias Coordinator = CodeViewCoordinator
    
    @MainActor public func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView(
            frame: CGRect(),
            textContainer: context.coordinator.textContainer
        )
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(width: CGFloat.infinity, height: CGFloat.infinity)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        // Set initial text
        textView.string = context.coordinator.text.wrappedValue
        // TODO make this configurable
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        
        let scrollView = NSScrollView()
        scrollView.documentView = textView
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autoresizingMask = [.width, .height]
        return scrollView
    }
    
    @MainActor public func updateNSView(_ scrollView: NSScrollView, context: Context) {
//        let textView = scrollView.documentView as! NSTextView
//        let ranges = textView.selectedRanges
//        defer { textView.selectedRanges = ranges }
        context.coordinator.update(self)
    }
}
#endif
