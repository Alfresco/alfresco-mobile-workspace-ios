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

class ImagePreview: UIView, FilePreviewProtocol {
    private var zoomImageView: ZoomImageView?
    private var task: ImageTask?
    private var gifImageView: GIFImageView?

    private var isRendaring: Bool = false
    private var imageRequest: ImageRequest?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false

        let zoomImageView = ZoomImageView(frame: frame)
        zoomImageView.setup()
        zoomImageView.imageContentMode = .aspectFit
        zoomImageView.initialOffset = .center
        zoomImageView.backgroundColor = .clear
        zoomImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(zoomImageView)

        self.zoomImageView = zoomImageView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Utils

    func display(for imagePreview: FilePreviewType, from url: URL, handler: @escaping(_ image: UIImage?, _ completedUnitCount: Int64, _ totalUnitCount: Int64, _ error: Error?) -> Void) {

        guard let imageView = self.zoomImageView?.zoomView as? UIImageView else { return }

        let resizeImage = CGSize(width: imageView.bounds.width * kMultiplerPreviewSizeImage,
                                 height: imageView.bounds.height * kMultiplerPreviewSizeImage)
        let imageRequest = ImageRequest(url: url, processors: [ImageProcessors.Resize(size: resizeImage)])
        self.imageRequest = imageRequest
        if let imageContainer = ImagePipeline.shared.cachedImage(for: imageRequest) {
            if imagePreview == .gif {
                display(imageContainer)
            } else {
                zoomImageView?.display(image: imageContainer.image)
            }
            handler(imageContainer.image, 0, 0, nil)
            return
        }

        switch imagePreview {
        case .gif:
            displayGIF { (image, error) in
                handler(image, 0, 0, error)
            }
        default:
            displayImage { (image, completedUnitCount, totalUnitCount, error) in
                handler(image, completedUnitCount, totalUnitCount, error)
            }
        }
    }

    private func displayImage(handler: @escaping(_ image: UIImage?, _ completedUnitCount: Int64, _ totalUnitCount: Int64, _ error: Error?) -> Void) {
        guard let imageView = self.zoomImageView?.zoomView as? UIImageView,
            let imageRequest = self.imageRequest else { return }
        isRendaring = true

        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline {
            $0.isDeduplicationEnabled = false
            $0.isProgressiveDecodingEnabled = true
        }
        ImageDecoderRegistry.shared.register { _ in return ImageDecoders.Default() }
        loadImage(with: imageRequest,
                  options: options,
                  into: imageView,
                  progress: { (response, completed, total) in
                    handler(response?.image, completed, total, nil)
        }, completion: { [weak self] (result) in
            guard let sSelf = self else { return }
            sSelf.isRendaring = false
            switch result {
            case .failure(let error):
                handler(nil, 0, 0, error)
            case .success(let response):
                sSelf.zoomImageView?.display(image: response.image)
                handler(response.image, 0, 0, nil)
            }
        })
    }

    private func displayGIF(handler: @escaping(_ image: UIImage?, _ error: Error?) -> Void) {
        guard let imageRequest = self.imageRequest else { return }

        ImageDecoderRegistry.shared.register { _ in return ImageDecoders.Default() }
        task = ImagePipeline.shared.loadImage(with: imageRequest) { [weak self] result in
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

    private func displaySVG(handler: @escaping(_ image: UIImage?, _ completedUnitCount: Int64, _ totalUnitCount: Int64, _ error: Error?) -> Void) {
    }

    // MARK: - Private Helpers

    private func display(_ container: Nuke.ImageContainer) {
        if let data = container.data {
            let imageView = GIFImageView()
            imageView.frame = frame
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.animate(withGIFData: data)
            zoomImageView?.display(image: imageView)
            gifImageView = imageView
        } else {
            zoomImageView?.display(image: container.image)
        }
    }

    private func animateFadeIn() {
        zoomImageView?.alpha = 0
        UIView.animate(withDuration: 0.33) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.zoomImageView?.alpha = 1
        }
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(themingService: MaterialDesignThemingService) {
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        zoomImageView?.frame = frame
        if isRendaring {
            zoomImageView?.zoomView?.frame = frame
        }
        gifImageView?.frame = frame
    }

    func cancel() {
        task?.cancel()
    }
}
