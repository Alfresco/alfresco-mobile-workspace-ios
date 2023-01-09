//
// Copyright (C) 2005-2020 Alfresco Software Limited.
//
// This file is part of the Alfresco Content Mobile iOS App.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit
import WebKit

class PlainTextPreview: UIView, FilePreviewProtocol {
    weak var filePreviewDelegate: FilePreviewDelegate?
    private var plainTextWebView: WKWebView?
    private var isFullScreen = false {
        didSet {
            filePreviewDelegate?.enableFullScreen(isFullScreen)
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: CGRect(origin: .zero, size: .zero))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        
        webView.navigationDelegate = self
        addSubview(webView)
        plainTextWebView = webView

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            webView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
            webView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
        ])

        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(viewTapped(_:)))
        tapGesture.delegate = self
        plainTextWebView?.addGestureRecognizer(tapGesture)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - IBActions

    @objc private func viewTapped(_ gestureRecognizer: UIGestureRecognizer) {
        isFullScreen = !isFullScreen
    }

    // MARK: - Public Helpers

    func display(text: Data) {
        if let url = URL(string: "http://localhost") {
            plainTextWebView?.load(text, mimeType: "text/plain",
                                   characterEncodingName: "UTF-8",
                                   baseURL: url)
        }
    }
    
    func display(from url: String?) {
        if let fileURL = url, let publicURL = URL(string: fileURL) {
            let request = URLRequest(url: publicURL)
            DispatchQueue.main.async {
                self.plainTextWebView?.load(request)
            }
        }
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        backgroundColor = currentTheme.backgroundColor
    }
}

// MARK: - WKNavigation Delegate

extension PlainTextPreview: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let topSafeArea = plainTextWebView?.scrollView.safeAreaInsets.top ?? 0
        plainTextWebView?.scrollView.contentInset = UIEdgeInsets(top: topSafeArea,
                                                                 left: 0,
                                                                 bottom: topSafeArea,
                                                                 right: 0)
        // Used topSafeArea insets for bottom in this case due to the fact that we extend the bounds of the container view for particular mime types past the safe areas
    }
}

// MARK: - UIGestureRecognizer Delegate

extension PlainTextPreview: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith
                            otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }
}
