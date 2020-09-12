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

class ImagePreview: UIView, FilePreviewProtocol {
    private var zoomImageView: ZoomImageView?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        let zoomImageView = ZoomImageView(frame: frame)
        zoomImageView.setup()
        zoomImageView.imageContentMode = .aspectFit
        zoomImageView.initialOffset = .center
        zoomImageView.backgroundColor = .clear
        addSubview(zoomImageView)

        self.zoomImageView = zoomImageView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Utils

    func displayImage(from url: URL, handler: @escaping(_ image: UIImage?, _ completedUnitCount: Int64, _ totalUnitCount: Int64, _ error: Error?) -> Void) {
        guard let imageView = self.zoomImageView?.zoomView else { return }

        var options = ImageLoadingOptions()
        options.pipeline = ImagePipeline {
            $0.isDeduplicationEnabled = false
            $0.isProgressiveDecodingEnabled = true
        }

        let resizeImage = CGSize(width: imageView.bounds.width * kMultiplerPreviewSizeImage,
                                 height: imageView.bounds.height * kMultiplerPreviewSizeImage)
        let imageRequest = ImageRequest(url: url, processors: [ImageProcessors.Resize(size: resizeImage)])

        loadImage(with: imageRequest,
                  options: options,
                  into: imageView,
                  progress: { (response, completed, total) in
                    handler(response?.image, completed, total, nil)
        }, completion: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .failure(let error):
                handler(nil, 0, 0, error)
            case .success(let response):
                sSelf.zoomImageView?.display(image: response.image)
                handler(response.image, 0, 0, nil)
            }
        })
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(themingService: MaterialDesignThemingService) {
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        zoomImageView?.frame = frame
    }

    func cancel() {
    }
}
