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

public protocol ZoomImageViewDelegate: UIScrollViewDelegate {
    func imageScrollViewDidChangeOrientation(imageViewZoom: ZoomImageView)
}

public enum ScaleMode: Int {
    case aspectFill
    case aspectFit
    case widthFill
    case heightFill
}

public enum Offset: Int {
    case begining
    case center
}

open class ZoomImageView: UIScrollView {

    static let kZoomInFactorFromMinWhenDoubleTap: CGFloat = 3

    open var imageContentMode: ScaleMode = .widthFill
    open var initialOffset: Offset = .begining

    public private(set) var zoomView: UIImageView?

    open weak var imageScrollViewDelegate: ZoomImageViewDelegate?

    var imageSize: CGSize = CGSize.zero
    private var pointToCenterAfterResize: CGPoint = CGPoint.zero
    private var scaleToRestoreAfterResize: CGFloat = 1.0
    var maxScaleFromMinScale: CGFloat = 4.0

    override open var frame: CGRect {
        willSet {
            if frame.equalTo(newValue) == false &&
                newValue.equalTo(CGRect.zero) == false &&
                imageSize.equalTo(CGSize.zero) == false {
                prepareToResize()
            }
        }
        didSet {
            if frame.equalTo(oldValue) == false &&
                frame.equalTo(CGRect.zero) == false &&
                imageSize.equalTo(CGSize.zero) == false {
                recoverFromResizing()
            }
        }
    }

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Utils

    private func initialize() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ZoomImageView.changeOrientationNotification),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    public func adjustFrameToCenter() {
        guard let unwrappedZoomView = zoomView else { return }
        var frameToCenter = unwrappedZoomView.frame
        if frameToCenter.size.width < bounds.width {
            frameToCenter.origin.x = (bounds.width - frameToCenter.size.width) / 2
        } else {
            frameToCenter.origin.x = 0
        }
        if frameToCenter.size.height < bounds.height {
            frameToCenter.origin.y = (bounds.height - frameToCenter.size.height) / 2
        } else {
            frameToCenter.origin.y = 0
        }
        unwrappedZoomView.frame = frameToCenter
    }

    private func prepareToResize() {
        let boundsCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        pointToCenterAfterResize = convert(boundsCenter, to: zoomView)
        scaleToRestoreAfterResize = zoomScale
        if scaleToRestoreAfterResize <= minimumZoomScale + CGFloat(Float.ulpOfOne) {
            scaleToRestoreAfterResize = 0
        }
    }

    private func recoverFromResizing() {
        setMaxMinZoomScalesForCurrentBounds()

        let maxZoomScale = max(minimumZoomScale, scaleToRestoreAfterResize)
        zoomScale = min(maximumZoomScale, maxZoomScale)

        let boundsCenter = convert(pointToCenterAfterResize, to: zoomView)
        var offset = CGPoint(x: boundsCenter.x - bounds.size.width / 2.0, y: boundsCenter.y - bounds.size.height / 2.0)

        let maxOffset = maximumContentOffset()
        let minOffset = minimumContentOffset()

        var realMaxOffset = min(maxOffset.x, offset.x)
        offset.x = max(minOffset.x, realMaxOffset)
        realMaxOffset = min(maxOffset.y, offset.y)
        offset.y = max(minOffset.y, realMaxOffset)
        contentOffset = offset
    }

    private func maximumContentOffset() -> CGPoint {
        return CGPoint(x: contentSize.width - bounds.width, y: contentSize.height - bounds.height)
    }

    private func minimumContentOffset() -> CGPoint {
        return CGPoint.zero
    }

    // MARK: - Set up

    open func setup() {
        var topSupperView = superview
        while topSupperView?.superview != nil {
            topSupperView = topSupperView?.superview
        }
        topSupperView?.layoutIfNeeded()
    }

    // MARK: - Display image

    open func display(image: UIImage) {
        if let zoomView = zoomView {
            zoomView.removeFromSuperview()
        }

        zoomView = UIImageView(image: image)
        zoomView!.isUserInteractionEnabled = true
        addSubview(zoomView!)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ZoomImageView.doubleTapGestureRecognizer(_:)))
        tapGesture.numberOfTapsRequired = 2
        zoomView!.addGestureRecognizer(tapGesture)

        configureImageForSize(image.size)
    }

    private func configureImageForSize(_ size: CGSize) {
        imageSize = size
        contentSize = imageSize
        setMaxMinZoomScalesForCurrentBounds()
        zoomScale = minimumZoomScale

        switch initialOffset {
        case .begining:
            contentOffset =  CGPoint.zero
        case .center:
            let xOffset = contentSize.width < bounds.width ? 0 : (contentSize.width - bounds.width) / 2
            let yOffset = contentSize.height < bounds.height ? 0 : (contentSize.height - bounds.height) / 2

            switch imageContentMode {
            case .aspectFit:
                contentOffset =  CGPoint.zero
            case .aspectFill:
                contentOffset = CGPoint(x: xOffset, y: yOffset)
            case .heightFill:
                contentOffset = CGPoint(x: xOffset, y: 0)
            case .widthFill:
                contentOffset = CGPoint(x: 0, y: yOffset)
            }
        }
    }

    private func setMaxMinZoomScalesForCurrentBounds() {
        let xScale = bounds.width / imageSize.width
        let yScale = bounds.height / imageSize.height
        var minScale: CGFloat = 1

        switch imageContentMode {
        case .aspectFill:
            minScale = max(xScale, yScale)
        case .aspectFit:
            minScale = min(xScale, yScale)
        case .widthFill:
            minScale = xScale
        case .heightFill:
            minScale = yScale
        }
        let maxScale = maxScaleFromMinScale * minScale
        if minScale > maxScale {
            minScale = maxScale
        }
        maximumZoomScale = maxScale
        minimumZoomScale = minScale * 0.999
    }

    // MARK: - Gesture

    @objc func doubleTapGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        if zoomScale >= maximumZoomScale / 2.0 {
            setZoomScale(minimumZoomScale, animated: true)
        } else {
            let center = gestureRecognizer.location(in: gestureRecognizer.view)
            let zoomRect = zoomRectForScale(ZoomImageView.kZoomInFactorFromMinWhenDoubleTap * minimumZoomScale, center: center)
            zoom(to: zoomRect, animated: true)
        }
    }

    private func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = frame.size.height / scale
        zoomRect.size.width  = frame.size.width  / scale
        zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0)
        zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

    open func refresh() {
        if let image = zoomView?.image {
            display(image: image)
        }
    }

    // MARK: - Actions

    @objc func changeOrientationNotification() {
        DispatchQueue.main.async { [weak self] in
            guard let sSelf = self else { return }
            sSelf.configureImageForSize(sSelf.imageSize)
            sSelf.imageScrollViewDelegate?.imageScrollViewDidChangeOrientation(imageViewZoom: sSelf)
        }
    }
}

extension ZoomImageView: UIScrollViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidScroll?(scrollView)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        imageScrollViewDelegate?.scrollViewWillEndDragging?(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        imageScrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewWillBeginDecelerating?(scrollView)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        imageScrollViewDelegate?.scrollViewWillBeginZooming?(scrollView, with: view)
    }

    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        imageScrollViewDelegate?.scrollViewDidEndZooming?(scrollView, with: view, atScale: scale)
    }

    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    @available(iOS 11.0, *)
    public func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        imageScrollViewDelegate?.scrollViewDidChangeAdjustedContentInset?(scrollView)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return zoomView
    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustFrameToCenter()
        imageScrollViewDelegate?.scrollViewDidZoom?(scrollView)
    }
}
