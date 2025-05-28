//
//  SFViewMondifier.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/14/25.
//

import SwiftUI

#if os(iOS) && !targetEnvironment(macCatalyst)
import SafariServices

extension URL: @retroactive Identifiable {
    public var id: String {
        return self.absoluteString
    }
}

public struct SFSafariView: UIViewControllerRepresentable {
    let url: URL

    public func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    public func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<Self>) {
        // No need to do anything here
    }
}
#endif


/// Monitors the `openURL` environment variable and handles them in-app instead of via
/// the external web browser.
public struct SFViewModifier: ViewModifier {
    @State private var urlToOpen: URL?

    public func body(content: Content) -> some View {
        content
#if os(iOS) && !targetEnvironment(macCatalyst)
            .environment(\.openURL, OpenURLAction { url in
                /// Catch any URLs that are about to be opened in an external browser.
                /// Instead, handle them here and store the URL to reopen in our sheet.
                guard let scheme = url.scheme?.lowercased(), ["https", "http"].contains(scheme) else {
                    return .systemAction
                }
                urlToOpen = url
                return .handled
            })
            .sheet(item: $urlToOpen, content: SFSafariView.init(url:))
#endif
    }
}

public extension View {
    func openURLSheet() -> some View {
        modifier(SFViewModifier())
    }
}
