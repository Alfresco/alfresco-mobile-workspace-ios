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
import WebKit

protocol PDFRendererPasswordDelegate: class {
    func providePDFPassword(for pdf: URL)
    func invalidPasswordProvided(for pdf: URL)
}

class PDFRenderer: UIView {
    var webView: WKWebView?
    var pdfURL: URL?
    weak var passwordDelegate: PDFRendererPasswordDelegate?

    // MARK: - Public interface

    override init(frame: CGRect) {
         super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }

    convenience init(with frame: CGRect, pdfURL: URL) {
        self.init(frame: frame)

        self.pdfURL = pdfURL
        self.translatesAutoresizingMaskIntoConstraints = false

        let config = WKWebViewConfiguration()

        let contentController = WKUserContentController()

        let userScript = WKUserScript(
            source: "DEFAULT_URL = \"\(pdfURL.absoluteString)\";",
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        contentController.addUserScript(userScript)
        contentController.add(self, name: "pdfAction")
        config.userContentController = contentController

        webView = WKWebView(frame: frame, configuration: config)
        guard let webView = self.webView else { return }

        webView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
            webView.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor, constant: 0),
            webView.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor, constant: 0),
            webView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])

        loadPDF(at: pdfURL)
    }

    func enableLogging() {
        webView?.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    }

    func loadPDF(at url: URL) {
        self.pdfURL = url
        guard let webView = self.webView else { return }

        let pdfjsLibraryPath = Bundle.main.path(forResource: "viewer-inlined.html", ofType: nil) ?? ""
        do {
            let libraryData = try Data(contentsOf: URL(fileURLWithPath: pdfjsLibraryPath))
            let libraryDataEncodedString = String(decoding: libraryData, as: UTF8.self)

            if let urlScheme = url.scheme, let urlHost = url.host {
                let baseURLDomainString = urlScheme + "://" + urlHost
                webView.loadHTMLString(libraryDataEncodedString, baseURL: URL(string: baseURLDomainString))
            }
        } catch {
            AlfrescoLog.error(("Unexpected error while loading PDF.js library: \(error)."))
        }
    }

    func unlockPDF(password: String) {
        webView?.evaluateJavaScript("PDFViewerApplication.onPassword(\"\(password)\")", completionHandler: { (_, error) in
            AlfrescoLog.error("Unexpected error while unlocking PDF document")
        })
    }
}

extension PDFRenderer: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "pdfAction" {
            if (message.body as? String) == "showPasswordPrompt" {
                if let url = pdfURL {
                    passwordDelegate?.providePDFPassword(for: url)
                }
            } else if (message.body as? String) == "invalidPasswordPrompt" {
                if let url = pdfURL {
                    passwordDelegate?.invalidPasswordProvided(for: url)
                }
            }
        }
    }
}
