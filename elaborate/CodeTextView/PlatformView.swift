//
//  PlatformView.swift
//  elaborate
//
//  Created by Brandon Roehl on 3/16/25.
//

import SwiftUI

#if os(macOS)
typealias OSView = NSView
#elseif os(iOS) || targetEnvironment(macCatalyst)
typealias OSView = UIView
#endif

internal extension View {
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

