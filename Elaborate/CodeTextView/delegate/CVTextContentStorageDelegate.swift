//
//  CVTextContentStorageDelegate.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import SwiftUI

func colorAttr(_ named: String) -> [NSAttributedString.Key: Any] {
	return [
		.font: OSMonoFont,
		.foregroundColor: OSColor(named: named) ?? OSColor.textFallbackColor
	]
}

/// Color asset for a capture name like `punctuation.braces`. The most
/// specific known prefix wins, nil means leave the text color alone.
private let highlightColors: [String: String] = [
	"keyword": "KeywordColor",
	"conditional": "KeywordColor",
	"repeat": "KeywordColor",
	"include": "KeywordColor",
	"exception": "KeywordColor",
	"string": "StringColor",
	"character": "StringColor",
	"escape": "StringColor",
	"number": "NumberColor",
	"float": "NumberColor",
	"comment": "CommentColor",
	"operator": "OperatorColor",
	"punctuation": "TextColor",
	"punctuation.braces": "BracesColor",
	"punctuation.delimiter": "DelimiterColor",
	"function": "FunctionColor",
	"method": "FunctionColor",
	"constructor": "FunctionColor",
	"type": "TypeColor",
	"constant": "ConstantColor",
	"boolean": "ConstantColor",
	"property": "PropertyColor",
	"field": "PropertyColor",
	"attribute": "PropertyColor",
	"tag": "PropertyColor",
	"variable": "TextColor",
]

func highlightColorName(for components: [String]) -> String? {
	var prefix = components
	while !prefix.isEmpty {
		if let name = highlightColors[prefix.joined(separator: ".")] { return name }
		prefix.removeLast()
	}
	return nil
}

extension CVCoordinator: @MainActor NSTextContentStorageDelegate {
    /// Swap the newline that ends a line for an attachment holding its results.
    /// The attachment is the same length as the newline so every offset in the
    /// text storage still lines up with the paragraph TextKit lays out.
    public func textContentStorage(_ textContentStorage: NSTextContentStorage, textParagraphWith range: NSRange) -> NSTextParagraph? {
        guard
            let storage = textContentStorage.textStorage,
            range.length > 0
        else {
            return nil
        }

		let paragraph = NSMutableAttributedString(attributedString: storage.attributedSubstring(from: range))
		
		paragraph.setAttributes(colorAttr("TextColor"), range: NSRange(location: 0, length: range.length))

		let rawString = paragraph.string

		// MARK: Highlight
		let bounds = NSRange(location: 0, length: range.length)
		for highlight in self.highlights(in: range) {
			guard let color = highlightColorName(for: highlight.nameComponents) else { continue }
			let local = NSRange(location: highlight.range.location - range.location, length: highlight.range.length)
			let clamped = NSIntersectionRange(local, bounds)
			guard clamped.length > 0 else { continue }
			paragraph.addAttributes(colorAttr(color), range: clamped)
		}

		// MARK: Insert the attachment

        let last = range.length - 1
        guard (rawString as NSString).character(at: last) == 0x0A else {
			return NSTextParagraph(attributedString: paragraph)
        }

        // The paragraph starts on the line its newline ends
        let line = self.lineIndex.lineNumber(at: range.location)
        guard let host = self.hosts[line] else {
			return NSTextParagraph(attributedString: paragraph)
        }

        let attributes = paragraph.attributes(at: last, effectiveRange: nil)
        let attachment = NSAttributedString(attachment: CodeAttachment(host: host), attributes: attributes)
        paragraph.replaceCharacters(in: NSRange(location: last, length: 1), with: attachment)
        return NSTextParagraph(attributedString: paragraph)
    }
}
