//
//  WebViewWrapper.swift
//  Weelar
//
//  Created by Sergey Monastyrskiy on 22.09.2021.
//

//import Combine
import WebKit
import SwiftUI

struct WebViewWrapper: UIViewRepresentable {
    // MARK: - Properties
    var url: URL?
    

    // MARK: - Functions
    func makeUIView(context: Context) -> WKWebView {
        let preferences = WKPreferences()
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
        
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        return webView
    
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let urlRequest = url {
            webView.load(URLRequest(url: urlRequest))
        }
    }
}
