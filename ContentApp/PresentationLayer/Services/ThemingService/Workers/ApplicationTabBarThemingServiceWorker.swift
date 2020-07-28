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

class ApplicationTabBarThemingServiceWorker: MaterialDesignThemingServiceWorkerProtocol {
    func containerScheme(for scene: MaterialComponentsThemingScene, on theme: PresentationTheme) -> MDCContainerScheming? {
        switch scene {
        case .applicationTabBar:
            return applicationTabBarContainerScheme(for: theme)
        default: return nil
        }
    }

    private func applicationTabBarContainerScheme(for theme: PresentationTheme) -> MDCContainerScheming {
        let containerScheme = MDCContainerScheme()
        containerScheme.colorScheme.primaryColor = theme.backgroundColor
        containerScheme.typographyScheme.caption = theme.captionTextStyle.font

        return containerScheme
    }
}
