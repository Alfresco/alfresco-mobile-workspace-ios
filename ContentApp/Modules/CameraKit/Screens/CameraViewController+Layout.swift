//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

let cameraFeature40Size = CGSize(width: 40, height: 40)
let cameraFeature16Size = CGSize(width: 16, height: 16)
let cameraMargin: CGFloat = 16.0

extension CameraViewController {
    
    // MARK: - Apply Themes
    
    func applyComponentsThemes() {
        guard let theme = CameraKit.theme else { return }

        view.backgroundColor = theme.surfaceColor

        closeButton.layer.cornerRadius = closeButton.bounds.height / 2.0
        closeButton.tintColor = theme.onSurface60Color
        closeButton.backgroundColor = theme.surface60Color
        
        flashModeButton.layer.cornerRadius = flashModeButton.bounds.height / 2.0
        flashModeButton.tintColor = theme.onSurface60Color
        flashModeButton.backgroundColor = theme.surface60Color

        switchCameraButton.layer.cornerRadius = switchCameraButton.bounds.height / 2.0
        switchCameraButton.tintColor = theme.onSurface60Color
        switchCameraButton.backgroundColor = theme.surface60Color
        
        zoomLabel.layer.cornerRadius = zoomLabel.bounds.height / 2.0
        zoomLabel.layer.masksToBounds = true
        zoomLabel.font = theme.subtitle2Font
        zoomLabel.textColor = theme.onSurfaceColor
        zoomLabel.backgroundColor = theme.surface60Color
        
        multiPhotosView.backgroundColor = .clear
        multiPhotosNumberIndicatorView.backgroundColor = theme.primaryColor
        multiPhotosNumberLabel.font = theme.overlineFont
        multiPhotosNumberLabel.textColor = theme.surfaceColor
        
        let image = UIImage(color: theme.surfaceColor,
                            size: navigationController?.navigationBar.bounds.size)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = theme.surfaceColor
        navigationController?.navigationBar.tintColor = theme.onSurface60Color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = theme.surfaceColor
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: theme.headline6Font,
             NSAttributedString.Key.foregroundColor: theme.onSurfaceColor]
    }
    
    // MARK: - Configure Layout Methods
    
    func configureViewsLayout(for size: CGSize) {
        let aspectRatio = sessionPreview.aspectRatio()
        let viewWidth = size.width
        let viewHeight = size.height
        
        topBarView.frame.size = CGSize(width: viewWidth, height: 56)
        flashMenuView.frame.size =  CGSize(width: 160, height: 160)
        zoomView.frame.size = CGSize(width: viewWidth, height: 64)
        shutterView.frame.size = CGSize(width: viewWidth, height: 96)
        modeView.frame.size = CGSize(width: viewWidth, height: 64)
        
        let topViewHeight = topBarView.bounds.height
        let zoomViewHeight = zoomView.bounds.height
        let shutterViewHeight = shutterView.bounds.height
        var modeViewHeight = modeView.bounds.height
        let flashMenuViewHeight = flashMenuView.bounds.height
        
        var topViewGuide: CGFloat = 0.0
        var flashMenuViewGuide: CGFloat = 0.0
        var finderViewGuide: CGFloat = 0.0
        var zoomViewGuide: CGFloat = 0.0
        var shutterViewGuide: CGFloat = 0.0
        var modeViewGuide: CGFloat = 0.0

        let finderView16by9 = min(viewHeight, (viewWidth * CameraAspectRatio.ar16by9.value))
        let finderView4by3 = min(viewHeight, (viewWidth * CameraAspectRatio.ar4by3.value))
        let expandedFinderView = max(finderView4by3, finderView16by9)
        let compactFinderView = min(finderView4by3, finderView16by9)
        let currentFinderView = min(viewHeight, (viewWidth * aspectRatio.value))
        let finderViewDiff = expandedFinderView - compactFinderView

        if topViewHeight + expandedFinderView <= viewHeight {
            modeViewHeight += max(0, finderViewDiff - (shutterViewHeight + modeViewHeight))
            let offset = (viewHeight - (topViewHeight + expandedFinderView)) / 2
            topViewGuide = offset
            finderViewGuide = topViewGuide + topViewHeight
            modeViewGuide = finderViewGuide + expandedFinderView - modeViewHeight
            shutterViewGuide = modeViewGuide - shutterViewHeight
        } else {
            modeViewHeight += max(0, finderViewDiff - shutterViewHeight - modeViewHeight)
            let offset = (viewHeight - expandedFinderView) / 2
            topViewGuide = offset
            finderViewGuide = offset
            modeViewGuide = finderViewGuide + expandedFinderView - modeViewHeight
            shutterViewGuide = modeViewGuide - shutterViewHeight
        }
        
        zoomViewGuide = shutterViewGuide - zoomViewHeight
        flashMenuViewGuide = topViewGuide + topViewHeight
        
        topBarView.frame = CGRect(x: 0, y: topViewGuide, width: viewWidth, height: topViewHeight)
        finderView.frame = CGRect(x: 0, y: finderViewGuide, width: viewWidth, height: currentFinderView)
        zoomView.frame = CGRect(x: 0, y: zoomViewGuide, width: viewWidth, height: zoomViewHeight)
        shutterView.frame = CGRect(x: 0, y: shutterViewGuide, width: viewWidth, height: shutterViewHeight)
        modeView.frame = CGRect(x: 0, y: modeViewGuide, width: viewWidth, height: modeViewHeight)

        flashMenuView.translatesAutoresizingMaskIntoConstraints = true
        flashMenuView.frame = CGRect(x: viewWidth - flashMenuViewHeight - cameraMargin,
                                     y: flashMenuViewGuide + cameraMargin,
                                     width: flashMenuViewHeight,
                                     height: flashMenuViewHeight)

        configureTopViewLayout()
        configureFinderViewLayout()
        configureZoomView()
        configureShutterView()
        configureModeView()
        configureTimerView()

    }
    
    private func configureTopViewLayout() {
        let topBarViewHeight = topBarView.frame.height
        let flashModeButtonX = topBarView.frame.width - flashModeButton.bounds.width - cameraMargin
        
        closeButton.frame.size = cameraFeature40Size
        closeButton.frame.origin = CGPoint(x: cameraMargin, y: 0)
        closeButton.center.y = topBarViewHeight / 2.0

        flashModeButton.frame.size = cameraFeature40Size
        flashModeButton.frame.origin = CGPoint(x: flashModeButtonX, y: 0)
        flashModeButton.center.y = topBarViewHeight / 2.0
    }
    
    private func configureFinderViewLayout() {
        sessionPreview.frame.origin = .zero
        sessionPreview.frame.size = finderView.frame.size
    }
    
    private func configureZoomView() {
        zoomLabel.frame.size = cameraFeature40Size
        zoomLabel.center = CGPoint(x: zoomView.frame.width / 2, y: zoomView.frame.height / 2)
        zoomSlider.center = zoomLabel.center
    }
    
    private func configureShutterView() {
        shutterButton.center = CGPoint(x: shutterView.frame.width / 2, y: shutterView.frame.height / 2)

        switchCameraButton.frame.size = cameraFeature40Size
        switchCameraButton.frame.origin.x = shutterView.frame.width
            - switchCameraButton.frame.width - cameraMargin
        switchCameraButton.center.y = shutterButton.center.y
        
        multiPhotosView.frame.size = cameraFeature40Size
        multiPhotosView.frame.origin.x = cameraMargin
        multiPhotosView.center.y = shutterButton.center.y
        
        multiPhotosImageView.frame.size = cameraFeature40Size
        multiPhotosImageView.frame.origin = .zero
        multiPhotosImageView.layer.cornerRadius = 8.0
        
        multiPhotosNumberIndicatorView.frame.size = cameraFeature16Size
        multiPhotosNumberIndicatorView.frame.origin.x = multiPhotosView.frame.height -
            multiPhotosNumberIndicatorView.frame.height * 0.70
        multiPhotosNumberIndicatorView.frame.origin.y = -multiPhotosNumberIndicatorView.frame.height * 0.30
        multiPhotosNumberIndicatorView.layer.cornerRadius = cameraFeature16Size.height / 2.0
        
        multiPhotosNumberLabel.frame.size = cameraFeature16Size
        multiPhotosNumberLabel.frame.origin = .zero
        
        multiPhotosButton.frame = multiPhotosImageView.frame
        
    }
    
    private func configureModeView() {
        modeSelector.center = CGPoint(x: modeView.frame.width / 2, y: modeView.frame.height / 2)
        modeSelector.translatesAutoresizingMaskIntoConstraints = true
    }

    private func configureTimerView() {
        timerView?.center = modeSelector.center
    }
}
