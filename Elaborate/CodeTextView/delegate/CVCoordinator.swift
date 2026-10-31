//
//  CVCoordinator.swift
//  Elaborate
//
//  Created by Brandon Roehl on 6/6/25.
//

import SwiftUI
import Elb

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

public class CVCoordinator: NSObject, NSTextStorageDelegate, NSTextContentStorageDelegate {
    
    #if os(macOS)
        nonisolated(unsafe) let OSMonoFont = NSFont(name: "JetBrains Mono", size: 9) ?? NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
    #elseif os(iOS) || targetEnvironment(macCatalyst)
        nonisolated(unsafe) let OSMonoFont = UIFont(name: "JetBrains Mono", size: 9) ?? UIFont.monospacedSystemFont(ofSize: 9, weight: .regular)
    #endif
    
    var text: Binding<String>
    var messages: [Int: ResultGroup]
    var lineHeight: Binding<[GutterRow]>?
    
    // MARK: - Text Stack

    nonisolated(unsafe) let textStorage = NSTextStorage()
    nonisolated(unsafe) let textContentStorage = NSTextContentStorage()
    nonisolated(unsafe) let textLayoutManager = NSTextLayoutManager()
    nonisolated(unsafe) let textContainer = NSTextContainer(size: CGSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
    
    // MARK: - Init
    
    @MainActor init(_ codeView: borrowing CodeTextView) {
        self.text = codeView.text
        self.messages = codeView.messages
        self.lineHeight = codeView.lineHeight
        super.init()
        
        // Zero padding so embedded message views span the full container
        // width, edge to edge.
        self.textContainer.lineFragmentPadding = 0
        
        // Wire up the TextKit 2 text stack
        self.textStorage.delegate = self
        self.textContentStorage.delegate = self
        self.textContentStorage.textStorage = self.textStorage
        self.textContentStorage.addTextLayoutManager(self.textLayoutManager)
        self.textLayoutManager.textContainer = self.textContainer
        
        // Register the view provider that hosts the message views
        NSTextAttachment.registerViewProviderClass(
            MessageViewProvider.self,
            forFileType: MessageAttachment.fileType
        )
        
        self.update(codeView)
    }
    
    // MARK: - Updates
    
    @MainActor func update(_ codeView: borrowing CodeTextView) {
        let oldMessages = self.messages
        self.text = codeView.text
        self.messages = codeView.messages
        self.lineHeight = codeView.lineHeight
        
        // Build the decorated buffer: every line that has a message gets an
        // attachment character (U+FFFC) at its linebreak.
        let buffer = Self.decorate(self.text.wrappedValue, self.messages)
        
        if buffer != self.textStorage.string {
            self.textStorage.setAttributedString(NSAttributedString(string: buffer))
        } else if oldMessages != self.messages {
            // Same buffer, but the message contents changed; re-fetch the
            // paragraphs so the attachments pick up the new results.
            self.textLayoutManager.invalidateLayout(for: self.textLayoutManager.documentRange)
        }
    }
    
    // MARK: - Decoration
    
    /// Builds the decorated buffer. Every line that has a message gets an
    /// attachment character (U+FFFC) on its own line directly below it.
    ///
    /// The code line and its newline are preserved (the attachment is *added
    /// at* the linebreak, not in place of it) so that line numbering,
    /// copy/paste and round-tripping all keep working. TextKit 2 then lays the
    /// attachment out on its own full-width line below the code line.
    static func decorate(_ text: String, _ messages: [Int: ResultGroup]) -> String {
        var lines: [String] = []
        var line = 1
        for piece in text.components(separatedBy: "\n") {
            lines.append(piece)
            if messages[line] != nil {
                lines.append("\u{FFFC}")
            }
            line += 1
        }
        return lines.joined(separator: "\n")
    }
    
    /// Removes the attachment characters to recover the plain source text.
    static func undecorate(_ buffer: String) -> String {
        buffer.replacingOccurrences(of: "\u{FFFC}", with: "")
    }
    
    /// The UTF-16 offsets of every newline in the buffer.
    public var newlineOffsets: [Int] {
        var offsets: [Int] = []
        var offset = 0
        for unit in self.textStorage.string.utf16 {
            if unit == 0x0A {
                offsets.append(offset)
            }
            offset += 1
        }
        return offsets
    }
    
    /// The 1-based source line number of the character at the given buffer
    /// offset.
    public func lineNumber(at offset: Int) -> Int {
        self.newlineOffsets.filter { $0 < offset }.count + 1
    }
    
    // MARK: - Heights
    
    /// Enumerates the visual lines of the layout and publishes one gutter row
    /// per line: numbered for code lines, unnumbered for message views.
    ///
    /// Each layout fragment corresponds to exactly one source line in the
    /// decorated buffer (the attachment rides on its own line at the end of
    /// the fragment). `NSTextLineFragment.characterRange` is relative to the
    /// fragment's paragraph, so the line number is tracked per fragment
    /// rather than looked up in the whole buffer.
    func syncHeights() {
        guard let gutter = self.lineHeight else {
            return
        }
        
        var rows: [GutterRow] = []
        var sourceLine = 1
        
        self.textLayoutManager.enumerateTextLayoutFragments(from: self.textLayoutManager.documentRange.location) { fragment in
            let paragraph = (
                self.textContentStorage
                    .attributedString(for: fragment.textElement ?? NSTextParagraph(attributedString: NSAttributedString(string: "")))?
                .string ?? ""
            ) as NSString
            var numbered = false
            
            for line in fragment.textLineFragments {
                let height = (line.typographicBounds.height * 10).rounded() / 10
                let substring = paragraph.substring(with: line.characterRange)
                
                if substring.contains("\u{FFFC}") {
                    // A message row; no line number.
                    rows.append(GutterRow(height: height))
                } else if numbered {
                    // A continuation of a wrapped code line; not renumbered.
                    rows.append(GutterRow(height: height))
                } else {
                    rows.append(GutterRow(height: height, line: sourceLine))
                    numbered = true
                }
            }
            sourceLine += 1
            return true
        }
        
        if gutter.wrappedValue != rows {
            gutter.wrappedValue = rows
        }
    }
}

extension CodeTextView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
