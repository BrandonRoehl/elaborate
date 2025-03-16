//
//  CodeViewLayoutDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

import SwiftUI

extension CodeViewCoordinator: NSTextLayoutManagerDelegate {
    public func textLayoutManager(
        _ textLayoutManager: NSTextLayoutManager,
        textLayoutFragmentFor location: NSTextLocation,
        in textElement: NSTextElement
    ) -> NSTextLayoutFragment {
        //        let index = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)
        //        let commentDepthValue = textContentStorage!.textStorage!.attribute(.commentDepth, at: index, effectiveRange: nil) as! NSNumber?
        //        if commentDepthValue != nil {
        //            let layoutFragment = BubbleLayoutFragment(textElement: textElement, range: textElement.elementRange)
        //            layoutFragment.commentDepth = commentDepthValue!.uintValue
        //            return layoutFragment
        //        } else {
        //        }
        let offset: Int = textLayoutManager.offset(from: textLayoutManager.documentRange.location, to: location)
        let line = self.paragraphRanges.firstIndex(where: { range in
            range.contains(offset)
        })

        print("Called for", location, "in", line, "with", textElement)

        guard let line, let result = self.results[line] else {
            // No line or result was found so return this unmodified
            // in the future we still need to do text highlighting
            return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
        }

        // TODO make this not this
        let attachment = DispatchQueue.main.sync {
            CodeAttachment(view: result)
        }
//        let attachment = CodeAttachment(view: result)
        attachment.coordinator = self
        let attachmentAttributedString = NSAttributedString(attachment: attachment)
        let attachmentPG = NSTextParagraph(attributedString: attachmentAttributedString)
//
//        if line >= pgs {
//            self.textStorage.append(attachmentAttributedString)
//        } else {
//            self.textStorage.paragraphs[line].append(attachmentAttributedString)
//        }
        return NSTextLayoutFragment(textElement: attachmentPG, range: textElement.elementRange)
    }
}

