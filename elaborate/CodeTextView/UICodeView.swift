//
//  codeview+ios.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(iOS)
import SwiftUI
import UIKit

extension CodeTextView: UIViewRepresentable {
    public typealias Coordinator = CVCoordinator
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(
            frame: CGRect(),
            textContainer: context.coordinator.textContainer
        )
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.autoresizingMask = []
        textView.backgroundColor = .clear
        textView.keyboardType = .numbersAndPunctuation
        return textView
        
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.update(self)
    }

    @MainActor public func sizeThatFits(_ proposal: ProposedViewSize, uiView textView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0 else {
            return nil
        }
        let container = context.coordinator.textContainer
        container.size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        
        let layout = context.coordinator.textLayoutManager
        layout.ensureLayout(for: layout.documentRange)
        let usedRect = layout.usageBoundsForTextContainer
        let newSize = proposal.replacingUnspecifiedDimensions(by: usedRect.size)
        Task.detached { @MainActor in
            context.coordinator.syncHeights()
        }
        return newSize
    }
}
#endif
