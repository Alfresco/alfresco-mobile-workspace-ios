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
import Nuke
import AVFoundation
import MaterialComponents.MaterialProgressView

class PreviewFileViewController: SystemThemableViewController {
    @IBOutlet weak var noPreviewLabel: UILabel!

    @IBOutlet weak var progressView: MDCProgressView!
    var previewFileViewModel: PreviewFileViewModel?

    var previewImageView: PreviewImageView?

    override func viewDidLoad() {
        super.viewDidLoad()

        noPreviewLabel.isHidden = true

        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)

        startLoading()
        previewFileViewModel?.requestFilePreview()

        appDelegate?.restrictRotation = .all
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false

        appDelegate?.restrictRotation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
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

    private func showNoPreview() {
        stopLoading()
        view.bringSubviewToFront(noPreviewLabel)
        noPreviewLabel.isHidden = false
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension PreviewFileViewController: PreviewFileViewModelDelegate {

    func displayPDF(from url: URL) {
        stopLoading()
        view.bringSubviewToFront(noPreviewLabel)
        noPreviewLabel.isHidden = false
    }

    func displayImage(from url: URL) {
        let viewHeight: CGFloat = self.view.bounds.size.height
        let viewWidth: CGFloat = self.view.bounds.size.width
        let previewImageView = PreviewImageView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight), and: self)
        self.previewImageView = previewImageView
        view.addSubview(previewImageView)

        previewImageView.displayImage(from: url) { [weak self] (_, completed, total, error) in
            guard let sSelf = self else { return }
            if let error = error {
                sSelf.showNoPreview()
                AlfrescoLog.error(error)
            }
            if completed == total {
                sSelf.stopLoading()
            }
        }
    }

    func display(error: Error) {
        self.showNoPreview()
    }

    func displayNoPreview() {
        self.showNoPreview()
    }
}

// MARK: - Storyboard Instantiable

extension PreviewFileViewController: StoryboardInstantiable { }

// MARK: - ZoomImageView Delegate

extension PreviewFileViewController: ZoomImageViewDelegate {
    func imageScrollViewDidChangeOrientation(imageViewZoom: ZoomImageView) {
        let viewHeight: CGFloat = self.view.bounds.size.height
        let viewWidth: CGFloat = self.view.bounds.size.width
        previewImageView?.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        previewImageView?.reloadImageViewZoomFrame()
    }
}
