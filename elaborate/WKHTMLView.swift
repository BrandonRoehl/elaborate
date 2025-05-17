//
//  WKHTMLView.swift
//  elaborate
//
//  Created by Brandon Roehl on 5/17/25.
//

import SwiftUI
import WebKit

struct WKHTMLView {
    let content: String
}

#if os(macOS)
extension WKHTMLView: NSViewRepresentable {
    func makeNSView(context: Context) -> WKWebView {
        let view = WKWebView()
        _ = view.loadHTMLString(self.content, baseURL: nil)
        return view
    }
    
    func updateNSView(_ webView: WKWebView, context: Context) { }
}
#elseif os(iOS) || targetEnvironment(macCatalyst)
extension WKHTMLView: UIViewRepresentable {
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        _ = view.loadHTMLString(self.content, baseURL: nil)
        return view
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {}
}
#endif
