//
//  CodeViewCoordinator.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/5/25.
//

import Foundation
import SwiftUI
import SwiftTreeSitter
import SwiftTreeSitterLayer
import os

/// Owns the TextKit 2 text view's state: the text binding, the result views
/// and the line bookkeeping used by the gutter and the attachments.
@MainActor
public final class CVCoordinator: NSObject {
    static let logger = Logger(subsystem: "elb", category: "coordinator")

    var text: Binding<String>
    var results: [Int: ResultGroup] = [:]

    weak var surface: (any CodeTextSurface)?

    /// One persistent hosted view per line that has results
    var hosts: [Int: ResultHost] = [:]
    var tailHost: ResultHost?

    private var cachedIndex: LineIndex?

    let language: LanguageLayer?
    /// Whether the language layer has parsed the current text
    private var languageParsed = false

    init(_ codeView: borrowing CodeTextView) {
        self.text = codeView.text
        self.language = codeView.language
        super.init()
    }

    // MARK: - Syntax tree

    /// Feed a text storage edit to the language layer. Offsets are UTF-16 code
    /// units, which the layer doubles into the bytes tree-sitter expects.
    func languageDidEdit(range editedRange: NSRange, changeInLength delta: Int) {
        guard let language else { return }
        guard self.languageParsed else {
            language.replaceContent(with: self.currentText)
            self.languageParsed = true
            return
        }
        let content = LanguageLayer.Content(string: self.currentText)
        let edit = InputEdit(
            startByte: editedRange.location * 2,
            oldEndByte: (editedRange.upperBound - delta) * 2,
            newEndByte: editedRange.upperBound * 2,
            startPoint: .zero,
            oldEndPoint: .zero,
            newEndPoint: .zero
        )
        language.didChangeContent(content, using: edit)
    }

    /// The highlight names and ranges (in storage coordinates) that touch `range`
    func highlights(in range: NSRange) -> [NamedRange] {
        guard let language else { return [] }
        if !self.languageParsed {
            language.replaceContent(with: self.currentText)
            self.languageParsed = true
        }
        let text = self.currentText
        do {
            return try language.highlights(in: range, provider: text.predicateTextProvider).sorted()
        } catch {
            Self.logger.error("highlighting failed: \(error)")
            return []
        }
    }

    // MARK: - Line bookkeeping

    var lineIndex: LineIndex {
        if let cachedIndex { return cachedIndex }
        let index = LineIndex(self.currentText)
        self.cachedIndex = index
        return index
    }

    var currentText: String {
        return self.textStorage?.string ?? ""
    }

    func invalidateLineIndex() {
        self.cachedIndex = nil
    }

    var contentStorage: NSTextContentStorage? {
        return self.surface?.textLayoutManager?.textContentManager as? NSTextContentStorage
    }

    var textStorage: NSTextStorage? {
        return self.contentStorage?.textStorage
    }

    // MARK: - Updates

    func attach(_ surface: some CodeTextSurface) {
        self.surface = surface
        self.contentStorage?.delegate = self
        self.textStorage?.delegate = self
    }

    func update(_ codeView: borrowing CodeTextView) {
        self.text = codeView.text

        // TODO: this check is very slow and also dumb but I don't have time
        if self.text.wrappedValue != self.currentText {
            self.contentStorage?.performEditingTransaction {
                self.textStorage?.setAttributedString(NSAttributedString(string: self.text.wrappedValue))
            }
        }
        self.apply(results: codeView.results)
    }

    /// Called after the user edits the text
    func textDidChangeByUser() {
        let newText = self.currentText
        if self.text.wrappedValue != newText {
            self.text.wrappedValue = newText
        }
    }

    /// The text changed (typing or the binding) so line derived state is stale
    func linesDidChange() {
        self.refreshGutterWidth()
        self.refreshFooter()
        self.surface?.refreshGutter()
    }

    private func apply(results new: [Int: ResultGroup]) {
        guard new != self.results else { return }
        let old = self.results
        self.results = new

        for (line, group) in new where old[line] != group {
            if let host = self.hosts[line] {
                host.setRoot(group)
            } else {
                self.hosts[line] = ResultHost(group)
            }
        }
        self.hosts = self.hosts.filter { new[$0.key] != nil }
        self.refreshFooter()

        // Rebuild the paragraphs so the attachments pick up the new views
        guard let storage = self.textStorage, storage.length > 0 else { return }
        let full = NSRange(location: 0, length: storage.length)
        self.contentStorage?.performEditingTransaction {
            storage.edited(.editedAttributes, range: full, changeInLength: 0)
        }
        self.surface?.refreshGutter()
    }

    // MARK: - Gutter and footer

    func refreshGutterWidth() {
        let digits = "\(max(self.lineIndex.lineCount, 1) * 10)"
        let width = ceil(digits.size(withAttributes: [.font: OSMonoFont]).width) + 8
        if let surface = self.surface, surface.gutterWidth != width {
            surface.gutterWidth = width
        }
    }

    /// Results for lines that have no newline to stand in for, ex. the last line
    func refreshFooter() {
        let terminated = self.lineIndex.newlines.count
        let tail = self.results.filter { $0.key > terminated }.sorted { $0.key < $1.key }.map(\.value)
        guard !tail.isEmpty else {
            self.tailHost = nil
            self.surface?.footer = nil
            return
        }
        let root = VStack(spacing: 0) {
            ForEach(tail.indices, id: \.self) { tail[$0] }
        }
        if let host = self.tailHost {
            host.setRoot(root)
        } else {
            let host = ResultHost(root)
            self.tailHost = host
            self.surface?.footer = host
        }
    }
}

extension CodeTextView {
    @MainActor public func makeCoordinator() -> CVCoordinator {
        return CVCoordinator(self)
    }
}
