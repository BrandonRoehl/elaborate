//
//  NSRange+Extension.swift
//  elaborate
//
//  Created by Brandon Roehl on 3/16/25.
//

import SwiftUI

extension NSRange {
    func convertToTextRange(in layoutManager: NSTextLayoutManager) -> NSTextRange? {
        let documentLocation = layoutManager.documentRange.location
        guard
            let startLocation = layoutManager.location(documentLocation, offsetBy: self.location),
            let endLocation = layoutManager.location(startLocation, offsetBy: self.length)
        else { return nil }
        
        return NSTextRange(location: startLocation, end: endLocation)
    }
}
