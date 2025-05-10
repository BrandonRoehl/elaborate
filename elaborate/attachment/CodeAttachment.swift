//
//  CodeAttachment.swift
//  CodeView
//
//  Created by Brandon Roehl on 3/16/25.
//

import SwiftUI

//class CodeAttachmentViewProvider: NSTextAttachmentViewProvider {
//    var uiView: AnyView? = nil
//
//    @MainActor
//    override func loadView() {
//        view = uiView?.platformView()
//    }
//}

//var thumbnailImage: NSImage? = // some image
//var attachmentCell: NSTextAttachmentCell = NSTextAttachmentCell.initImageCell(thumbnailImage!)
//var attachment: NSTextAttachment = NSTextAttachment()
//attachment.attachmentCell = attachmentCell
//var attrString: NSAttributedString = NSAttributedString.attributedStringWithAttachment(attachment)
//self.textView.textStorage().appendAttributedString(attrString)

final class CodeAttachment: NSTextAttachment {
    let view: OSView

    public init(view: OSView) {
        self.view = view
        self.view.autoresizingMask = [.height]
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
//        viewProvider.tracksTextAttachmentViewBounds = true
        viewProvider.view = self.view
        return viewProvider
    }
    
    override func attachmentBounds(for attributes: [NSAttributedString.Key : Any], location: any NSTextLocation, textContainer: NSTextContainer?, proposedLineFragment: CGRect, position: CGPoint) -> CGRect {
//        if size.height < 100 {
//            size.height = 100
//        }
//        textContainer?.textView?.frame.width
        
//        return CGRect(origin: .zero, size: size)
        var result = CGRect()
        self.view.autoresizingMask = [.height]
        var size = self.view.intrinsicContentSize
        if let width = textContainer?.size.width {
            size.width = width
        } else {
            size.width = proposedLineFragment.width
        }
        result.size = size
        result.origin = CGPoint(x: proposedLineFragment.origin.x, y: proposedLineFragment.maxY)
        return result
//        return CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
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
