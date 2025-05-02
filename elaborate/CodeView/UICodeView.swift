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
}
#endif
