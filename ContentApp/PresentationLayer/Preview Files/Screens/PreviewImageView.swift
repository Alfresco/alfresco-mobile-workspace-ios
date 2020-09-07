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

class PreviewImageView: UIView {
     private var imageViewZoom: ZoomImageView?
     private var scrooViewZoom: UIScrollView?

    // MARK: - Init

    init(frame: CGRect, and previewImageViewDelegate: ZoomImageViewDelegate) {
        super.init(frame: frame)
        let viewHeight: CGFloat = self.bounds.size.height
        let viewWidth: CGFloat = self.bounds.size.width

        let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight))
        let imageViewZoom = ZoomImageView(frame: scrollView.frame)

        imageViewZoom.setup()
        imageViewZoom.imageContentMode = .aspectFit
        imageViewZoom.initialOffset = .center
        imageViewZoom.imageScrollViewDelegate = previewImageViewDelegate
        if let image = UIImage(named: "emptyList") {
            imageViewZoom.display(image: image)
        }

        scrollView.contentSize = CGSize(width: 0, height: viewHeight)
        scrollView.addSubview(imageViewZoom)
        addSubview(scrollView)

        self.imageViewZoom = imageViewZoom
        self.scrooViewZoom = scrollView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Utils

    func displayImage(from url: URL, handler: @escaping(_ image: UIImage?, _ completedUnitCount: Int64, _ totalUnitCount: Int64, _ error: Error?) -> Void) {
        guard let imageView = self.imageViewZoom?.zoomView else { return }

        loadImage(with: ImageRequest(url: url, processors: [ImageProcessors.Resize(size: imageView.bounds.size)]),
                  options: ImageLoadingOptions(),
                  into: imageView,
                  progress: { [weak self] (response, completed, total) in
                    guard let sSelf = self else { return }
                    if let image = response?.image {
                        sSelf.imageViewZoom?.display(image: image)
                    }
                    handler(response?.image, completed, total, nil)
        }, completion: { [weak self] (result) in
            guard let sSelf = self else { return }
            switch result {
            case .failure(let error):
                handler(nil, 0, 0, error)
            case .success(let response):
                sSelf.imageViewZoom?.display(image: response.image)
                handler(response.image, 0, 0, nil)
            }
        })
    }

    func reloadImageViewZoomFrame() {
        let viewHeight: CGFloat = self.bounds.size.height
        let viewWidth: CGFloat = self.bounds.size.width
        scrooViewZoom?.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        imageViewZoom?.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
        scrooViewZoom?.contentSize = CGSize(width: 0, height: viewHeight)
    }
}
