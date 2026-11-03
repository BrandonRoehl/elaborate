//
//  ResultHost.swift
//  elaborate
//

import SwiftUI

#if os(macOS)
typealias OSHostingController = NSHostingController<AnyView>
#else
typealias OSHostingController = UIHostingController<AnyView>
#endif

/// Keeps a SwiftUI view (and the controller that owns it) alive so the same
/// platform view can be handed to TextKit every time a paragraph is rebuilt.
@MainActor
final class ResultHost {
    let controller: OSHostingController
    var view: OSView { controller.view }

    init(_ root: some View) {
        self.controller = OSHostingController(rootView: AnyView(root))
#if os(iOS)
        self.controller.view.backgroundColor = .clear
#endif
    }

    func setRoot(_ root: some View) {
        self.controller.rootView = AnyView(root)
    }

    /// Fill the width, fit the height
    func size(fitting width: CGFloat) -> CGSize {
        let proposed = CGSize(width: max(width, 0), height: .greatestFiniteMagnitude)
        var size = self.controller.sizeThatFits(in: proposed)
        size.width = proposed.width
        return size
    }
}
