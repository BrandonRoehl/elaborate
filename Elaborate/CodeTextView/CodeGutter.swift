//
//  CodeGutter.swift
//  elaborate
//

import SwiftUI

struct GutterLine {
    let number: Int
    /// Frame of the first line fragment, in text view coordinates
    let rect: CGRect
}

/// What the coordinator needs from the platform text view
@MainActor
protocol CodeTextSurface: AnyObject {
    var textLayoutManager: NSTextLayoutManager? { get }
    var gutterWidth: CGFloat { get set }
    var footer: ResultHost? { get set }
    /// Where the text container starts in text view coordinates
    var containerOrigin: CGPoint { get }
    func refreshGutter()
}

enum GutterRenderer {
    static func textAttributes() -> [NSAttributedString.Key: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = .right
#if os(macOS)
        let color = NSColor.labelColor
#else
        let color = UIColor.label
#endif
        return [.font: OSMonoFont, .foregroundColor: color, .paragraphStyle: style]
    }

    static var backgroundColor: OSColor {
#if os(macOS)
        NSColor.labelColor.withAlphaComponent(0.06)
#else
        UIColor.label.withAlphaComponent(0.06)
#endif
    }

    /// Draw `lines` into the current graphics context. `originY` is the top of
    /// the view being drawn into, in text view coordinates.
    static func draw(_ lines: [GutterLine], originY: CGFloat, width: CGFloat) {
        let attributes = textAttributes()
        for line in lines {
            let rect = CGRect(x: 4, y: line.rect.minY - originY, width: max(width - 8, 0), height: line.rect.height)
            ("\(line.number)" as NSString).draw(in: rect, withAttributes: attributes)
        }
    }
}

extension CVCoordinator {
    /// The numbered lines (one per paragraph) that intersect `rect`.
    /// Positions come straight from TextKit's layout fragments so the gutter
    /// always agrees with the text, including around result attachments.
    func gutterLines(in rect: CGRect) -> [GutterLine] {
        guard
            let surface = self.surface,
            let layout = surface.textLayoutManager,
            let content = layout.textContentManager as? NSTextContentStorage
        else {
            return []
        }
        let index = self.lineIndex
        let origin = surface.containerOrigin
        let width = surface.gutterWidth
        let local = rect.offsetBy(dx: -origin.x, dy: -origin.y)

        let start = layout.textLayoutFragment(for: CGPoint(x: 0, y: max(local.minY, 0)))?.rangeInElement.location
            ?? layout.documentRange.location

        var lines: [GutterLine] = []
        var lastFragment: NSTextLayoutFragment?
        var reachedEnd = true
        layout.enumerateTextLayoutFragments(from: start, options: [.ensuresLayout]) { fragment in
            if fragment.layoutFragmentFrame.minY > local.maxY {
                reachedEnd = false
                return false
            }
            lastFragment = fragment
            guard let first = fragment.textLineFragments.first else { return true }
            let offset = content.offset(from: content.documentRange.location, to: fragment.rangeInElement.location)
            let bounds = first.typographicBounds
            lines.append(GutterLine(
                number: index.lineNumber(at: offset),
                rect: CGRect(
                    x: 0,
                    y: origin.y + fragment.layoutFragmentFrame.minY + bounds.minY,
                    width: width,
                    height: bounds.height
                )
            ))
            return true
        }

        // A trailing newline leaves an empty line that has no fragment of its own
        if reachedEnd, index.endsWithNewline, let fragment = lastFragment,
           let extra = fragment.textLineFragments.last, extra.characterRange.length == 0 {
            lines.append(GutterLine(
                number: index.lineCount,
                rect: CGRect(
                    x: 0,
                    y: origin.y + fragment.layoutFragmentFrame.minY + extra.typographicBounds.minY,
                    width: width,
                    height: extra.typographicBounds.height
                )
            ))
        }

        if lines.isEmpty && index.length == 0 {
            let height = ceil(OSMonoFont.ascender - OSMonoFont.descender)
            lines.append(GutterLine(number: 1, rect: CGRect(x: 0, y: origin.y, width: width, height: height)))
        }
        return lines
    }
}
