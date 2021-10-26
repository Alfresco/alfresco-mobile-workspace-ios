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
import PDFKit

class PDFRenderer: UIView {
    
    var pdfURL: URL?
    
    var pdfBackgroundColor: UIColor?
    private var pdfView: PDFView?
    private var pdfPassword: String?
    private var pageViewOverlay: UIView?
    private var pageCountLabel: UILabel?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(with frame: CGRect, pdfURL: URL) {
        self.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.pdfURL = pdfURL
        if self.isLocalURL() {
            self.loadPDFUsingNativeRenderer()
        }
    }
    
    // MARK: - Private interface
    
    private func isLocalURL() -> Bool {
        guard let pdfURL = self.pdfURL else { return false }
        return pdfURL.absoluteString.hasPrefix("file:///")
    }
    
    private func addPageCountView() {
        let pageViewOverlay = UIView()
        let pageCountLabel = UILabel()
        pageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        pageCountLabel.textColor = .white
        pageCountLabel.font = .systemFont(ofSize: 10)
        pageCountLabel.textAlignment = .center
        
        pageViewOverlay.translatesAutoresizingMaskIntoConstraints = false
        pageViewOverlay.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)
        pageViewOverlay.layer.cornerRadius = 3
        pageViewOverlay.layer.masksToBounds = true
        pageViewOverlay.alpha = 0
        
        addSubview(pageViewOverlay)
        pageViewOverlay.addSubview(pageCountLabel)
        
        self.pageViewOverlay = pageViewOverlay
        self.pageCountLabel = pageCountLabel
        
        NSLayoutConstraint.activate([
            self.leftAnchor.constraint(equalTo: pageViewOverlay.leftAnchor, constant: -15),
            self.bottomAnchor.constraint(equalTo: pageViewOverlay.bottomAnchor, constant: 60),
            pageViewOverlay.widthAnchor.constraint(equalToConstant: 60),
            pageViewOverlay.heightAnchor.constraint(equalToConstant: 25),
            pageViewOverlay.bottomAnchor.constraint(equalTo: pageCountLabel.bottomAnchor, constant: 0),
            pageViewOverlay.topAnchor.constraint(equalTo: pageCountLabel.topAnchor, constant: 0),
            pageViewOverlay.leftAnchor.constraint(equalTo: pageCountLabel.leftAnchor, constant: -4),
            pageViewOverlay.rightAnchor.constraint(equalTo: pageCountLabel.rightAnchor, constant: 4)
        ])
    }
    
    private func showPageCountView() {
        UIView.animate(withDuration: 0.25) {
            self.pageViewOverlay?.alpha = 1
            
            UIView.animate(withDuration: 0.25, delay: 2, animations: {
                self.pageViewOverlay?.alpha = 0
            })
        }
    }
    
    func loadPDFUsingNativeRenderer(pdfTempUrl: URL? = nil) {
        // Fallback to native PDFKit if webview rendering fails or is out of memory
        
        let pdfView = PDFView(frame: self.bounds)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(pdfView)
        addPageCountView()
        
        self.pdfView = pdfView
        if let pdfURL = self.pdfURL ?? pdfTempUrl {
            if let pdfDocument = PDFDocument(url: pdfURL) {
                if pdfDocument.isLocked {
                    pdfDocument.unlock(withPassword: pdfPassword ?? "")
                }
                pdfView.document = pdfDocument
            }
        }
        
        if let backgroundColor = pdfBackgroundColor {
            pdfView.backgroundColor = backgroundColor
        }
        
        pdfView.maxScaleFactor = 10.0
        pdfView.minScaleFactor = pdfView.scaleFactorForSizeToFit
        pdfView.autoScales = true
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: pdfView.topAnchor, constant: 0),
            self.leftAnchor.constraint(equalTo: pdfView.leftAnchor, constant: 0),
            self.rightAnchor.constraint(equalTo: pdfView.rightAnchor, constant: 0),
            self.bottomAnchor.constraint(equalTo: pdfView.bottomAnchor, constant: 0)
        ])
        
        // Add page changed listener
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePageChange(notification:)),
            name: Notification.Name.PDFViewPageChanged,
            object: nil)
    }
}

// MARK: - Page numbers handling
extension PDFRenderer {
    @objc private func handlePageChange(notification: Notification) {
        if let currentPage = pdfView?.currentPage?.pageRef?.pageNumber,
           let totalNoOfPages = pdfView?.document?.pageCount {
            showPageCountView()
            pageCountLabel?.text = String(format: "%d of %d", currentPage, totalNoOfPages)
        }
    }
}
