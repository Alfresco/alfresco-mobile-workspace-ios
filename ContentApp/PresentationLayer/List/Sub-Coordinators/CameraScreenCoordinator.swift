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

class CameraScreenCoordinator: Coordinator {
    private let presenter: UINavigationController
    private var navigationViewController: UINavigationController?
    private var cameraViewController: CameraViewController?
    
    init(with presenter: UINavigationController) {
        self.presenter = presenter
    }
    
    func start() {
        let viewController = CameraViewController.instantiateViewController()
        viewController.theme = configurationLayout()
        viewController.localization = cameraLocalization()
        
        let navigationViewController = UINavigationController(rootViewController: viewController)
        navigationViewController.modalPresentationStyle = .fullScreen
        presenter.present(navigationViewController, animated: true)
        
        self.navigationViewController = navigationViewController
        cameraViewController = viewController
    }
    
    // MARK: - Private Methods

    func configurationLayout() -> CameraConfigurationLayout? {
        guard let currentTheme = themingService?.activeTheme else { return nil}
        let theme = CameraConfigurationLayout()

        theme.onSurfaceColor = currentTheme.onSurfaceColor
        theme.onSurface60Color = currentTheme.onSurface60Color
        theme.surfaceColor = currentTheme.surfaceColor
        theme.subtitle2Font = currentTheme.subtitle2TextStyle.font

        return theme
    }
    
    func cameraLocalization() -> CameraLocalization {
        let localization = CameraLocalization()
        
        localization.sliderPhoto = LocalizationConstants.Camera.sliderCameraPhoto
        
        return localization
    }
}
