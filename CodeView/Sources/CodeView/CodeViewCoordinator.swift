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
    var results: [Int: AnyView]

    @MainActor init<T>(_ codeView: borrowing CodeView<T>) {
        self.text = codeView.$text
        self.results = codeView.results.mapValues { AnyView($0) }

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
        self.results = codeView.results.mapValues { AnyView($0) }

        // At the end refresh the contents
        self.refreshView()
    }
    
    @MainActor private func refreshView() {
//        // Make sure the selection and cursor doesn't move
//        let selections = self.textLayoutManager.textSelections
//        defer { self.textLayoutManager.textSelections = selections }
//
        // Re-load the text without formatting
//        self.textStorage.setAttributedString(NSAttributedString(string: self.text.wrappedValue))
        for (line, view) in self.results {
            let insertIndex = textLayoutManager.documentRange.location
            
            let view = view.platformView()
            let attachment = NSTextAttachment(data: nil, ofType: nil)
            let provider = NSTextAttachmentViewProvider(textAttachment: attachment, parentView: view, textLayoutManager: self.textLayoutManager, location: insertIndex)
//            self.textContentStorage.performEditingTransaction {
//                self.textStorage.insert(attachment, at: insertIndex as! Int)
//            }
        }
    }
}

fileprivate extension View {
#if os(macOS)
    @MainActor @inline(__always) func platformView() -> some NSView {
        return NSHostingView(rootView: self)
    }
#elseif os(iOS) || targetEnvironment(macCatalyst)
    @MainActor @inline(__always) func platformView() -> some UIView {
        return UIHostingController(rootView: self).view
    }
#endif
}

extension CodeView {
    @MainActor public func makeCoordinator() -> CodeViewCoordinator {
        return CodeViewCoordinator(self)
    }
}
