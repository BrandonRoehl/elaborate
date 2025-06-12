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
    
    override func attachmentBounds(for attributes: [NSAttributedString.Key : Any], location: any NSTextLocation, textContainer: NSTextContainer?, proposedLineFragment: CGRect, position: CGPoint) -> CGRect {
        var result = CGRect()
        
        let width = textContainer?.size.width ?? proposedLineFragment.width
        #if os(macOS)
//        let constraint: NSLayoutConstraint
//        if let f = self.view.constraints.first {
//            constraint = f
//        } else {
//            constraint = self.view.widthAnchor.constraint(equalToConstant: width)
//            NSLayoutConstraint.activate([constraint])
//        }
//        constraint.constant = width
//        if self.view.window != nil {
//            self.view.needsLayout = true
//            self.view.layoutSubtreeIfNeeded()
//        }
        self.view.setFrameSize(CGSize(width: width, height: 10_000))
        var size = self.view.fittingSize
        #else
        var size = self.view.sizeThatFits(CGSize(width: width, height: .infinity))
        #endif
        size.width = width
        result.size = size
        result.origin = CGPoint(x: proposedLineFragment.origin.x, y: proposedLineFragment.maxY)
        return result
    }
}

