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
    private var plainTextWebView: WKWebView?

    // MARK: - Init

    init() {
        super.init(frame: CGRect(origin: .zero, size: .zero))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        let webView = WKWebView()
        webView.backgroundColor = .clear
        webView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(webView)
        plainTextWebView = webView

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            webView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            webView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public Helpers

    func display(text: Data) {
        if let url = URL(string: "http://localhost") {
            plainTextWebView?.load(text, mimeType: "text/plain", characterEncodingName: "UTF-8", baseURL: url)
        }
    }
}
