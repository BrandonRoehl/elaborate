//
//  CodeAttachment.swift
//  CodeView
//
//  Created by Brandon Roehl on 3/16/25.
//

import SwiftUI

class CodeAttachment: NSTextAttachment {
    let view: OSView
    weak var coordinator: CodeViewCoordinator?

    @MainActor
    public init(view: AnyView) {
        self.view = view.platformView()
        super.init(data: nil, ofType: nil)
    }
    
    required init?(coder: NSCoder) {
        self.view = coder.decodeObject(of: OSView.self, forKey: .init("view"))!
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.prepareForInterfaceBuilder()
        coder.encode(view, forKey: .init("view"))
        super.encode(with: coder)
    }
    
    override func viewProvider(for parentView: OSView?, location: NSTextLocation, textContainer: NSTextContainer?) -> NSTextAttachmentViewProvider? {
        // TODO We might need to provide a custom view provider
        let viewProvider = NSTextAttachmentViewProvider(textAttachment: self, parentView: parentView,
                                                        textLayoutManager: textContainer?.textLayoutManager,
                                                        location: location)
        viewProvider.tracksTextAttachmentViewBounds = true
        viewProvider.view = self.view
        return viewProvider
    }

//    func toggleHidden() {
//        guard let textStorage: NSTextStorage = (textLayoutManager?.textContentManager as? NSTextContentStorage)?.textStorage else { return }
//        textLayoutManager?.textContentManager?.performEditingTransaction {
//            if hiddenContent != nil { // Showing
//                let ellipsisRange = NSRange(location: textStorage.length - 2, length: 1)
//                textStorage.replaceCharacters(in: ellipsisRange, with: hiddenContent!)
//                hiddenContent = nil
//            } else { // Hiding
//                let firstParagraphRange = NSRange(location: 0, length: 331)
//                let hidingRange = NSRange(location: NSMaxRange(firstParagraphRange), length: textStorage.length - NSMaxRange(firstParagraphRange) - 1)
//                hiddenContent = textStorage.attributedSubstring(from: hidingRange)
//                textStorage.replaceCharacters(in: hidingRange, with: "…")
//            }
//        }
//    }
}
