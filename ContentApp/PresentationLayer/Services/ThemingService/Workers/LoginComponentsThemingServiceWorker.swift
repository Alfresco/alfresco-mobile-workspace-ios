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

class LoginComponentsThemingServiceWorker: MaterialDesignThemingServiceWorkerProtocol {

    func containerScheme(for scene: MaterialComponentsThemingScene, on theme: PresentationTheme) -> MDCContainerScheming? {
        switch scene {
        case .loginButton:
            return loginButtonContainerScheme(for: theme)
        case .loginTextField:
            return loginTextFieldContainerScheme(for: theme)
        case .loginAdvancedSettingsButton:
            return loginAdvancedSettingsButtonContainerScheme(for: theme)
        case .loginNeedHelpButton:
            return loginNeedHelpButtonContainerScheme(for: theme)
        case .loginResetButton:
            return loginResetButtonContainerScheme(for: theme)
        case .loginSavePadButton:
            return loginSavePadButtonContainerScheme(for: theme)
        default: return nil
        }
    }

    // MARK: - Helpers

    private func loginButtonContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.primaryVariantColor
        containerScheme.colorScheme.onPrimaryColor = theme.onPrimaryColor
        containerScheme.typographyScheme.button = theme.subtitle2TextStyle.font

        return containerScheme
    }

    private func loginAdvancedSettingsButtonContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.primaryVariantColor
        containerScheme.typographyScheme.button = theme.body2TextStyle.font

        return containerScheme
    }

    private func loginNeedHelpButtonContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.onBackgroundColor.withAlphaComponent(0.6)
        containerScheme.typographyScheme.button = theme.body2TextStyle.font

        return containerScheme
    }

    private func loginResetButtonContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.primaryVariantColor
        containerScheme.typographyScheme.button = theme.buttonTextStyle.font

        return containerScheme
    }

    private func loginSavePadButtonContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.primaryVariantColor
        containerScheme.typographyScheme.button = theme.body1TextStyle.font

        return containerScheme
    }

    private func loginTextFieldContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.primaryColor
        containerScheme.colorScheme.onSurfaceColor = theme.onSurfaceColor
        containerScheme.colorScheme.errorColor = theme.errorColor
        containerScheme.typographyScheme.subtitle1 = theme.body1TextStyle.font

        return containerScheme
    }
}
