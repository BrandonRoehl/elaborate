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

let OSMonoFont: OSFont = {
    let size = OSFont.systemFontSize
    return OSFont.monospacedSystemFont(ofSize: size, weight: .regular)
}()
