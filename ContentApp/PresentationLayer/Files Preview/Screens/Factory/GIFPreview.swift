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
import Nuke
import Gifu

class GIFPreview: UIView, FilePreviewProtocol {
    private var task: ImageTask?
    private var imageView: GIFImageView?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let imageView = GIFImageView()
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .clear
        addSubview(imageView)
        self.imageView = imageView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Helpers

    func displayGIF(from url: URL, handler: @escaping(_ image: UIImage?, _ error: Error?) -> Void) {
        let resizeImage = CGSize(width: imageView?.bounds.width ?? 0 * kMultiplerPreviewSizeImage,
                                 height: imageView?.bounds.height ?? 0 * kMultiplerPreviewSizeImage)
        let imageRequest = ImageRequest(url: url, processors: [ImageProcessors.Resize(size: resizeImage)])
        let pipeline = ImagePipeline.shared

        if let image = pipeline.cachedImage(for: imageRequest) {
            handler(image.image, nil)
            return display(image)
        }

        task = pipeline.loadImage(with: imageRequest) { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let response):
                handler(response.image, nil)
                sSelf.display(response.container)
                sSelf.animateFadeIn()
            case .failure(let error):
                handler(nil, error)
            }
        }
    }

    // MARK: - Private Helpers

    private func display(_ container: Nuke.ImageContainer) {
        if let data = container.data {
            imageView?.animate(withGIFData: data)
        } else {
            imageView?.image = container.image
        }
    }

    private func animateFadeIn() {
        imageView?.alpha = 0
        UIView.animate(withDuration: 0.33) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.imageView?.alpha = 1
        }
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(themingService: MaterialDesignThemingService) {
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        imageView?.frame = frame
    }

    func cancel() {
        task?.cancel()
    }
}
