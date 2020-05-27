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
import MaterialComponents.MaterialContainerScheme

protocol MaterialDesignThemingServiceWorkerProtocol {
    func containerScheme(for scene: MaterialComponentsThemingScene, on theme: PresentationTheme) -> MDCContainerScheming?
}

class LoginComponentsThemingServiceWorker: MaterialDesignThemingServiceWorkerProtocol {
    func containerScheme(for scene: MaterialComponentsThemingScene, on theme: PresentationTheme) -> MDCContainerScheming? {
        switch scene {
        case .loginButton:
            return loginButtonContainerScheme(for: theme)
        case .loginURLTextField:
            print("")
        case .loginAdvancedSettingsButton:
            print("")
        case .loginNeedHelpButton:
            print("")
        }

        return MDCContainerScheme()
    }

    // MARK: - Helpers
    private func loginButtonContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.loginButtonColor
        containerScheme.typographyScheme.button = UIFont.boldSystemFont(ofSize: 16)

        return containerScheme
    }

    private func loginURLTextFieldContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.loginURLTextFieldPrimaryColor
        containerScheme.colorScheme.onSurfaceColor = theme.loginURLTextFieldOnSurfaceColor
        containerScheme.typographyScheme.subtitle1 = theme.loginUrlTextFieldFont

        return containerScheme
    }
}
