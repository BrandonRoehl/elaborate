//
//  codeview+ios.swift
//  CodeView
//
//  Created by Brandon Roehl on 1/3/25.
//

#if os(iOS)
import SwiftUI
import UIKit

/// Line number gutter that lives inside the text view and scrolls with it
final class CodeGutterView: UIView {
    weak var coordinator: CVCoordinator?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isOpaque = false
        backgroundColor = .clear
        contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        GutterRenderer.backgroundColor.setFill()
        UIRectFill(rect)
        guard let coordinator else { return }
        let visible = CGRect(x: 0, y: frame.minY + rect.minY, width: bounds.width, height: rect.height)
        GutterRenderer.draw(coordinator.gutterLines(in: visible), originY: frame.minY, width: bounds.width)
    }
}

final class CodeUITextView: UITextView, CodeTextSurface {
    let gutter = CodeGutterView()

    var gutterWidth: CGFloat = 0 {
        didSet {
            guard oldValue != gutterWidth else { return }
            updateInsets(footerHeight: footerHeight)
            setNeedsLayout()
        }
    }

    var footer: ResultHost? {
        didSet {
            guard oldValue !== footer else { return }
            oldValue?.view.removeFromSuperview()
            if let footer {
                addSubview(footer.view)
            }
            setNeedsLayout()
        }
    }

    private var footerHeight: CGFloat = 0

    var containerOrigin: CGPoint {
        CGPoint(x: textContainerInset.left, y: textContainerInset.top)
    }

    func refreshGutter() {
        gutter.setNeedsDisplay()
    }

    private func updateInsets(footerHeight: CGFloat) {
        self.footerHeight = footerHeight
        let insets = UIEdgeInsets(top: 0, left: gutterWidth, bottom: footerHeight, right: 0)
        if textContainerInset != insets {
            textContainerInset = insets
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if gutter.superview == nil {
            addSubview(gutter)
        }
        if let footer, let layout = textLayoutManager {
            let width = textContainer.size.width
            let height = footer.size(fitting: width).height
            if height != footerHeight {
                updateInsets(footerHeight: height)
            }
            let used = layout.usageBoundsForTextContainer
            footer.view.frame = CGRect(x: gutterWidth, y: textContainerInset.top + used.maxY, width: width, height: height)
        } else if footerHeight != 0 {
            updateInsets(footerHeight: 0)
        }

        // Only back the part of the gutter that is on screen
        let frame = CGRect(x: 0, y: bounds.minY, width: gutterWidth, height: bounds.height)
        if gutter.frame != frame {
            gutter.frame = frame
        }
        gutter.setNeedsDisplay()
    }
}

extension CodeTextView: UIViewRepresentable {
    public typealias Coordinator = CVCoordinator

    public func makeUIView(context: Context) -> UITextView {
        let textView = CodeUITextView(usingTextLayoutManager: true)
        textView.gutter.coordinator = context.coordinator
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.backgroundColor = .clear
        textView.keyboardType = .numbersAndPunctuation
        textView.keyboardDismissMode = .interactive
        textView.font = OSMonoFont
        textView.delegate = context.coordinator

        context.coordinator.attach(textView)
        context.coordinator.update(self)
        context.coordinator.linesDidChange()
        return textView
    }

    public func updateUIView(_ textView: UITextView, context: Context) {
        context.coordinator.update(self)
    }
}

extension CVCoordinator: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        self.textDidChangeByUser()
    }
}
#endif
