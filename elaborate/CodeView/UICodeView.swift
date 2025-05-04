//
//  codeview+ios.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(iOS) || targetEnvironment(macCatalyst)
import SwiftUI
import UIKit

extension CodeView: UIViewRepresentable {
    public typealias Coordinator = CodeViewCoordinator
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(
            frame: CGRect(),
            textContainer: context.coordinator.textContainer
        )
        return textView
        
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
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
        container.containerSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        layout.ensureLayout(for: container)
        let usedRect = layout.usedRect(for: container)
        let newSize = proposal.replacingUnspecifiedDimensions(by: usedRect.size)
        return newSize
    }
}
#endif
