//
//  PlatformView.swift
//  elaborate
//
//  Created by Brandon Roehl on 3/16/25.
//

import SwiftUI

#if os(macOS)
typealias OSView = NSView
typealias OSFont = NSFont
#else
typealias OSView = UIView
typealias OSFont = UIFont
#endif

internal extension View {
#if os(macOS)
    @MainActor @inline(__always) func platformView() -> some NSView {
        return NSHostingView(rootView: self)
    }
#else
    @MainActor @inline(__always) func platformView() -> some UIView {
        return UIHostingController(rootView: self).view
    }
#endif
}

#if os(macOS)
nonisolated(unsafe) let OSMonoFont: NSFont = {
    let size = NSFont.systemFontSize
    return NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
}()
#else
let OSMonoFont: UIFont = {
    let size = UIFont.systemFontSize
    return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
}()
#endif
