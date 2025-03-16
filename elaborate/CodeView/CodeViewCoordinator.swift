//
//  CodeViewCoordinator.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import Foundation
import SwiftUI

/** Push `NSTextContentStorage` changes through `NSTextContentManager`
`NSTextContentManager.performEditingTransaction(_ transaction: () -> Void)`
*/

//struct BindingUpdates: OptionSet {
//    let rawValue: Int8
//
//    static let text = BindingUpdates(rawValue: 1 << 0)
//    static let results = BindingUpdates(rawValue: 1 << 1)
//
//    static let all: BindingUpdates = [.text, .results]
//}

public class CodeViewCoordinator: NSObject {
    let textStorage: NSTextStorage
    let textContainer: NSTextContainer
    let textLayoutManager: NSTextLayoutManager
    let textContentStorage: NSTextContentStorage

    var text: Binding<String>
    var results: [Int: OSView]

    @MainActor init<T>(_ codeView: borrowing CodeView<T>) {
        self.text = codeView.$text
        self.results = codeView.results.mapValues { $0.platformView() }

        // Initilize the container first
        self.textStorage = NSTextStorage()
        self.textContainer = NSTextContainer()
        self.textLayoutManager = NSTextLayoutManager()
        self.textContentStorage = NSTextContentStorage()

        super.init()

        // MARK: NSTextStorageDelegate
        self.textStorage.delegate = self

        // MARK: NSTextLayoutManagerDelegate
        self.textLayoutManager.delegate = self

        // MARK: NSTextContentStorageDelegate
        self.textContentStorage.delegate = self
        self.textContentStorage.textStorage = self.textStorage
        self.textContentStorage.addTextLayoutManager(self.textLayoutManager)

        // Update the text container
        self.textLayoutManager.textContainer = self.textContainer
        
        // At the end refresh the contents
        self.refreshView()
    }

    @MainActor func update<T>(_ codeView: borrowing CodeView<T>) {
        self.text = codeView.$text
        self.results = codeView.results.mapValues { $0.platformView() }

        // At the end refresh the contents
        self.refreshView()
    }
    
    @MainActor private func refreshView() {
//        // Make sure the selection and cursor doesn't move
//        let selections = self.textLayoutManager.textSelections
//        defer { self.textLayoutManager.textSelections = selections }
        
//        for (line, _) in self.results {
//            guard
//                line < self.paragraphRanges.count,
//                let range = self.paragraphRanges[line].convertToTextRange(in: self.textLayoutManager)
//            else { continue }
//            print("Invalidating", range)
//            self.textLayoutManager.invalidateLayout(for: range)
//            self.textLayoutManager.ensureLayout(for: range)
//            
//        }
        // Re-load the text without formatting
//        self.textStorage.setAttributedString(NSAttributedString(string: self.text.wrappedValue))
        // Notify that the content has changed
        
        for (line, _) in self.results {
            guard line < self.paragraphRanges.count else { continue }
            let range = self.paragraphRanges[line]
            textContentStorage.processEditing(for: self.textStorage, edited: .editedAttributes, range: range, changeInLength: range.length, invalidatedRange: range)
        }

        // For views using TextKit 2
//        textView.layoutManager.ensureLayout(for: textView.visibleRect)
        
        // get the reverse sort of the lines so we don't mess up the indexes
        // somehow do this without editing the view
//        let pgs = self.textStorage.paragraphs.count
//        let lines = self.results.keys.sorted(by: >)
//        self.performSuppressedEditingTransaction {
//            for line in lines {
//                let attachment = CodeAttachment(view: self.results[line]!)
//                attachment.coordinator = self
//                let attachmentAttributedString = NSAttributedString(attachment: attachment)
//                let newPG = NSTextParagraph(attributedString: attachmentAttributedString)
//                
//                if line >= pgs {
//                    self.textStorage.append(attachmentAttributedString)
//                } else {
//                    self.textStorage.paragraphs[line].append(attachmentAttributedString)
//                }
//            }
//        }
    }
    
    var paragraphRanges: [NSRange] = []

    let editing = NSLock()

    @MainActor
    func performSuppressedEditingTransaction(_ transaction: () -> Void) {
        self.editing.withLock {
            self.textContentStorage.performEditingTransaction {
                transaction()
            }
        }
    }
}


extension CodeView {
    @MainActor public func makeCoordinator() -> CodeViewCoordinator {
        return CodeViewCoordinator(self)
    }
}
