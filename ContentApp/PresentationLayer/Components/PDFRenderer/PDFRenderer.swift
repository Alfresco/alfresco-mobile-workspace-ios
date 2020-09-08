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
import GCDWebServer

class PDFRenderer: NSObject {
    let webView = WKWebView()
    let webServer = GCDWebServer()
    var pdfURL: URL?

    // MARK: - Public interface

    init(with pdfURL: URL) {
        super.init()

        self.pdfURL = pdfURL
        let pdfjsPath = Bundle.main.path(forResource: "pdfjs-library", ofType: nil)

        // Register request handlers to route all requests to the PDF.js viewer file
        webServer.addGETHandler(forBasePath: "/", directoryPath: pdfjsPath!, indexFilename: nil, cacheAge: 3600, allowRangeRequests: true)
        webServer.addHandler(forMethod: "GET", path: "/", request: GCDWebServerRequest.self) { (request) -> GCDWebServerResponse? in
            return GCDWebServerResponse(redirect: URL(string: "viewer.html", relativeTo: request.url)!, permanent: false)
        }

        // Register request handler to route all PDF file requests to server content
        webServer.addHandler(forMethod: "GET", pathRegex: "placeholder.pdf", request: GCDWebServerRequest.self) { [weak self] _ -> GCDWebServerResponse? in
            guard let sSelf = self else { return nil }

            if let pdfURL = sSelf.pdfURL {
                // If loading a local PDF, stream the file using a GCDWebServer file response type
                if "file" == pdfURL.scheme {
                    let response = GCDWebServerFileResponse(file: pdfURL.absoluteString)
                    response?.setValue("bytes", forAdditionalHeader: "Accept-Ranges")
                    return response
                } else {
                    do {
                        let pdfData = try Data(contentsOf: pdfURL)
                        let response = GCDWebServerDataResponse(data: pdfData, contentType: "application/pdf")
                        response.setValue(sSelf.webServer.bonjourServerURL?.absoluteString,
                                          forAdditionalHeader: "Access-Control-Allow-Origin")
                        response.setValue("GET, POST, DELETE, PUT, OPTIONS, HEAD",
                                          forAdditionalHeader: "Access-Control-Allow-Methods")
                        response.setValue("Accept, Content-Type, Access-Control-Allow-Origin",
                                          forAdditionalHeader: "Access-Control-Allow-Headers")
                        response.setValue("bytes",
                                          forAdditionalHeader: "Accept-Ranges")
                    } catch {
                        AlfrescoLog.error("Unable to fetch content for PDF at URL: \(pdfURL)")
                    }
                }
            }

            return nil
        }

        if let serverName = Bundle.main.infoDictionary!["CFBundleDisplayName"] as? String {
            webServer.start(withPort: 8080, bonjourName: "\(serverName)-PDFService")
        }
    }

    func enableLogging() {
        GCDWebServer.setLogLevel(0)
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    }

    func loadPDF(at url: URL) {
        self.pdfURL = url
        loadPDF(on: webServer)
    }

    // MARK: - Private interface

    private func loadPDF(on server: GCDWebServer) {
        if let bonjourServiceURL = server.bonjourServerURL {
            let request = URLRequest(url: bonjourServiceURL)
            webView.load(request)
        }
    }
}

extension PDFRenderer: GCDWebServerDelegate {
    func webServerDidCompleteBonjourRegistration(_ server: GCDWebServer) {
        loadPDF(on: server)
    }
}
