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
        return NSTextLayoutFragment(textElement: textElement, range: textElement.elementRange)
    }
}

