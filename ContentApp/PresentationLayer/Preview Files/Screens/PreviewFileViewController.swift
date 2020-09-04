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
    @IBOutlet weak var imagePreview: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        noPreviewLabel.isHidden = true

        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)

        startLoading()
        previewFileViewModel?.requestFilePreview()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        loadImage(with: ImageRequest(url: url, processors: [ImageProcessors.Resize(size: imagePreview.bounds.size)]),
                  options: ImageLoadingOptions(),
                  into: imagePreview,
                  progress: { [weak self] (_, completed, total) in
                    guard let sSelf = self else { return }
                    if completed == total {
                        sSelf.stopLoading()
                    }
        }) { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .failure(let error):
                sSelf.showNoPreview()
                AlfrescoLog.error(error)
            case .success(_):
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

// MARK: - UIScrollViewDelegate

extension PreviewFileViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imagePreview
    }
}

// MARK: - Storyboard Instantiable

extension PreviewFileViewController: StoryboardInstantiable { }
