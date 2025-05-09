//
//  codeview+ios.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(iOS) || targetEnvironment(macCatalyst)
import SwiftUI
import UIKit

extension CodeTextView: UIViewRepresentable {
    public typealias Coordinator = CVCoordinator
    
    public func makeUIView(context: Context) -> UITextView {
        let textView = UITextView(
            frame: CGRect(),
            textContainer: context.coordinator.textContainer
        )
        textView.font = .monospacedSystemFont(ofSize: Self.fontSize, weight: .regular)
        textView.textColor = .label
        textView.isScrollEnabled = false
        textView.textContainerInset = .zero
        return textView
        
    }
    
    public func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.update(self)
    }

    @MainActor public func sizeThatFits(_ proposal: ProposedViewSize, uiView textView: UITextView, context: Context) -> CGSize? {
        guard let width = proposal.width, width > 0 else {
            return nil
        }
        let container = textView.textContainer
        let layout = textView.layoutManager
        container.size = CGSize(width: width, height: .greatestFiniteMagnitude)
        layout.ensureLayout(for: container)
        let usedRect = layout.usedRect(for: container)
        let newSize = proposal.replacingUnspecifiedDimensions(by: usedRect.size)
        return newSize
    }
}
#endif
