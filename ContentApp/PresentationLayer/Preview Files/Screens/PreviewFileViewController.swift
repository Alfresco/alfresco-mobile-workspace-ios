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

import UIKit
import PDFKit
import AVKit
import AVFoundation
import MaterialComponents.MaterialProgressView

class PreviewFileViewController: SystemThemableViewController {
    @IBOutlet weak var noPreviewLabel: UILabel!
    @IBOutlet weak var progressView: MDCProgressView!
    var previewFileViewModel: PreviewFileViewModel?
    var pdfView: PDFView?
    var textView: UITextView?
    var imageView: UIImageView?
    var playerLayer: AVPlayerLayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        noPreviewLabel.isHidden = true

        logicViews()

        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)
        startLoading()

        previewFileViewModel?.request()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playerLayer?.player = nil
        playerLayer?.player?.replaceCurrentItem(with: nil)
        playerLayer = nil
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Private Helpers

    private func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: false)
    }

    private func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
    }

    private func logicViews() {
        switch FilePreview.preview(mimetype: previewFileViewModel?.node.mimeType) {
        case .pdf, .renditionPdf:
            addPDFView()
        case .text:
            addTextView()
        case .image:
            addImageView()
        case .video, .audio:
            addPlayerLayerView()
        default:
            noPreviewLabel.isHidden = false
        }
    }

    private func addPDFView() {
        pdfView = PDFView()
        if let pdfView = pdfView {
            view.addSubview(pdfView)

            pdfView.translatesAutoresizingMaskIntoConstraints = false
            pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }

    private func addTextView() {
        textView = UITextView()
        if let textView = textView {
            view.addSubview(textView)

            textView.translatesAutoresizingMaskIntoConstraints = false
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

            textView.isEditable = false
            textView.isSelectable = true
            textView.text = ""
        }
    }

    private func addImageView() {
        imageView = UIImageView()
        if let imageView = imageView {
            view.addSubview(imageView)

            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

            imageView.contentMode = .scaleAspectFit
        }
    }

    private func addPlayerLayerView() {
        playerLayer = AVPlayerLayer()
        if let playerLayer = playerLayer {
            playerLayer.frame = view.bounds
            view.layer.addSublayer(playerLayer)
        }
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension PreviewFileViewController: PreviewFileViewModelDelegate {
    func display(video: URL) {
        stopLoading()
        playerLayer?.player = AVPlayer(url: video)
        playerLayer?.player?.play()
    }

    func display(image: UIImage) {
        stopLoading()
        imageView?.image = image
    }

    func display(text: String) {
        stopLoading()
        textView?.text = text
    }

    func display(pdf data: Data) {
        stopLoading()
        pdfView?.document = PDFDocument(data: data)
    }

    func display(error: Error) {
        stopLoading()
        view.bringSubviewToFront(noPreviewLabel)
        noPreviewLabel.isHidden = false
    }
}

// MARK: - Storyboard Instantiable

extension PreviewFileViewController: StoryboardInstantiable { }
