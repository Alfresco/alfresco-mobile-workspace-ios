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
import SVGKit

public typealias ImagePreviewHandler = (_ image: UIImage?, _ error: Error?) -> Void

class ImagePreview: UIView, FilePreviewProtocol {

    weak var filePreviewDelegate: FilePreviewDelegate?
    private var zoomImageView: ZoomImageView?
    private var imageRequest: ImageRequest?
    private var imagePreviewHandler: ImagePreviewHandler?

    private var task: ImageTask?
    private var gifImageView: GIFImageView?

    private var svgImageView: SVGKImage?
    private var svgImageSize: CGSize?

    private var isRendering: Bool = false
    private var numberOfTaps: Int = 0
    private var fullScreenTimer: Timer?
    private var isFullScreen: Bool = false {
        didSet {
            if isRendering == false {
                filePreviewDelegate?.enableFullScreen(isFullScreen)
            }
        }
    }

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
        zoomImageView.contentInsetAdjustmentBehavior = .never
        addSubview(zoomImageView)
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(ImagePreview.zoomImageTapGestureRecognizer(_:)))
        zoomImageView.addGestureRecognizer(tapGesture)

        self.zoomImageView = zoomImageView
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Public Utils

    func display(for imagePreview: FilePreviewType, from url: URL, handler: @escaping ImagePreviewHandler) {

        guard let imageView = self.zoomImageView?.zoomView as? UIImageView else { return }
        isRendering = true
        let resizeImage = CGSize(width: imageView.bounds.width * kMultiplerPreviewSizeImage,
                                 height: imageView.bounds.height * kMultiplerPreviewSizeImage)
        let imageRequest = ImageRequest(url: url, processors: [ImageProcessors.Resize(size: resizeImage)])

        if let imageCachedContainer = ImagePipeline.shared.cachedImage(for: imageRequest) {
            if imagePreview == .gif {
                display(imageCachedContainer)
            } else {
                zoomImageView?.display(image: imageCachedContainer.image)
            }
            isRendering = false
            handler(imageCachedContainer.image, nil)
            return
        }
        self.imageRequest = imageRequest
        self.imagePreviewHandler = handler

        switch imagePreview {
        case .gif:
            displayGIF()
        case .svg:
            displaySVG()
        default:
            displayImage()
        }
    }

    // MARK: - Private Helpers

    @objc private func zoomImageTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        numberOfTaps += 1
        fullScreenTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] (_) in
            guard let sSelf = self, sSelf.numberOfTaps == 1 else { return }
            sSelf.isFullScreen = !sSelf.isFullScreen
            sSelf.numberOfTaps = 0
        })
        if numberOfTaps == 2 {
            numberOfTaps = 0
            fullScreenTimer?.invalidate()
            if gifImageView == nil {
                zoomImageView?.doubleTapGestureRecognizer(gestureRecognizer)
            }
        }
    }

    private func displayImage() {
        guard let imageView = self.zoomImageView?.zoomView as? UIImageView,
            let imageRequest = self.imageRequest,
            let handler = imagePreviewHandler else { return }

        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline {
            $0.isDeduplicationEnabled = false
            $0.isProgressiveDecodingEnabled = true
        }
        ImageDecoderRegistry.shared.register { _ in return ImageDecoders.Default() }
        task = loadImage(with: imageRequest,
                         options: options,
                         into: imageView,
                         progress: nil,
                         completion: { [weak self] (result) in
                            guard let sSelf = self else { return }
                            sSelf.isRendering = false

                            switch result {
                            case .failure(let error):
                                handler(nil, error)
                            case .success(let response):
                                sSelf.zoomImageView?.display(image: response.image)
                                handler(response.image, nil)
                            }
                         })
    }

    private func displayGIF() {
        guard let imageRequest = self.imageRequest, let handler = imagePreviewHandler else { return }

        ImageDecoderRegistry.shared.register { _ in return ImageDecoders.Default() }
        task = ImagePipeline.shared.loadImage(with: imageRequest, completion: { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .success(let response):
                sSelf.isRendering = false
                handler(response.image, nil)
                sSelf.display(response.container)
                sSelf.animateFadeIn()
            case .failure(let error):
                handler(nil, error)
            }
        })
    }

    private func displaySVG() {
        guard let url = self.imageRequest?.urlRequest.url,
            let handler = imagePreviewHandler else { return }
        ImageDecoderRegistry.shared.register { _ in return ImageDecoders.Empty() }
        task = ImagePipeline.shared.loadImage(with: url, completion: { [weak self] result in
            guard let sSelf = self else { return }
            switch result {
            case .failure(let error):
                handler(nil, error)
            case .success(let response):
                sSelf.isRendering = false
                if let data = response.container.data {
                    if let svgImage = SVGKImage(data: data) {
                        sSelf.svgImageSize = svgImage.size
                        svgImage.size = sSelf.resizeSVG()
                        sSelf.svgImageView = svgImage
                        sSelf.zoomImageView?.display(image: svgImage.uiImage)
                        handler(svgImage.uiImage, nil)
                    }
                }
                handler(nil, nil)
            }
        })
    }

    private func resizeSVG() -> CGSize {
        guard let size = svgImageSize else { return frame.size}
        let widthRatio  = frame.width  / size.width
        let heightRatio = frame.height / size.height

        if widthRatio > heightRatio {
            return CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            return CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
    }

    private func display(_ container: Nuke.ImageContainer) {
        if let data = container.data {
            let imageView = GIFImageView()
            imageView.frame = frame
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            imageView.image = container.image
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

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        zoomImageView?.frame = frame
        gifImageView?.frame = frame
        if isRendering {
            zoomImageView?.zoomView?.frame = frame
        }
        if svgImageView != nil {
            zoomImageView?.zoomView?.frame.size = resizeSVG()
        }
    }

    func cancel() {
        task?.cancel()
        task?.priority = .high
        task = nil
        zoomImageView?.removeFromSuperview()
        fullScreenTimer?.invalidate()
    }
}
