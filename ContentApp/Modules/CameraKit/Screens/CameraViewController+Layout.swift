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
        let cameraHeight = min(viewHeight, viewWidth * aspectRatio.value)
        
        topBarView.frame.size = CGSize(width: viewWidth, height: 56)
        flashMenuView.frame.size =  CGSize(width: 160, height: 160)
        finderView.frame.size = CGSize(width: viewWidth, height: cameraHeight)
        zoomView.frame.size = CGSize(width: viewWidth, height: 64)
        shutterView.frame.size = CGSize(width: viewWidth, height: 96)
        modeView.frame.size = CGSize(width: viewWidth, height: 64)
        
        let topViewHeight = topBarView.bounds.height
        let finderViewHeight = finderView.bounds.height
        let zoomViewHeight = zoomView.bounds.height
        let shutterViewHeight = shutterView.bounds.height
        let modeViewHeight = modeView.bounds.height
        let flashMenuViewHeight = flashMenuView.bounds.height
        
        var topViewGuide: CGFloat = 0.0
        var flashMenuViewGuide: CGFloat = 0.0
        var finderViewGuide: CGFloat = 0.0
        var zoomViewGuide: CGFloat = 0.0
        var shutterViewGuide: CGFloat = 0.0
        var modeViewGuide: CGFloat = 0.0
        
        let case1 = topViewHeight + finderViewHeight + shutterViewHeight + modeViewHeight
        let case2 = topViewHeight + finderViewHeight + modeViewHeight
        let case3 = topViewHeight + finderViewHeight
        
        if case1 <= viewHeight { // All elemets fits
            let offset = (viewHeight - (case1)) / 2
            topViewGuide = offset
            flashMenuViewGuide = topViewGuide + topViewHeight
            finderViewGuide = topViewGuide + topViewHeight
            shutterViewGuide = finderViewGuide + finderViewHeight
            modeViewGuide = shutterViewGuide + shutterViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        } else if case2 <= viewHeight { // All elemets except the shutter fits
            let offset = (viewHeight - (case2)) / 2
            topViewGuide = offset
            flashMenuViewGuide = topViewGuide + topViewHeight
            finderViewGuide = topViewGuide + topViewHeight
            shutterViewGuide = finderViewGuide + finderViewHeight - shutterViewHeight
            modeViewGuide = finderViewGuide + finderViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        } else if case3 <= viewHeight { // Only the top bar and finder fits
            let offset = (viewHeight - (case3)) / 2
            topViewGuide = offset
            flashMenuViewGuide = topViewGuide + topViewHeight
            finderViewGuide = topViewGuide + topViewHeight
            modeViewGuide = finderViewGuide + finderViewHeight - modeViewHeight
            shutterViewGuide = modeViewGuide - shutterViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        } else { // Overlay everything on top of the finder
            let offset = (viewHeight - finderViewHeight) / 2
            topViewGuide = offset
            finderViewGuide = offset
            flashMenuViewGuide = topViewGuide + topViewHeight
            modeViewGuide = finderViewGuide + finderViewHeight - modeViewHeight
            shutterViewGuide = modeViewGuide - shutterViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        }
        
        topBarView.frame = CGRect(x: 0, y: topViewGuide, width: viewWidth, height: topViewHeight)
        finderView.frame = CGRect(x: 0, y: finderViewGuide, width: viewWidth, height: finderViewHeight)
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
    }
    
    private func configureModeView() {
        cameraSlider.center = CGPoint(x: modeView.frame.width / 2, y: modeView.frame.height / 2)
        cameraSlider.translatesAutoresizingMaskIntoConstraints = true
    }
}
