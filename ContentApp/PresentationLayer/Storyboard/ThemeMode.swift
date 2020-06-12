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

enum ThemeModeType: String {
    case auto = "Auto"
    case dark = "Dark"
    case light = "Light"
}

class ThemeMode {
    class func save(mode: ThemeModeType, themingService: MaterialDesignThemingService?) {
        UserDefaults.standard.set(mode.rawValue, forKey: kSaveThemeMode)
        UserDefaults.standard.synchronize()
        AlfrescoLog.debug("Theme \(mode.rawValue) was saved in UserDefaults.")

        var userInterfaceStyle: UIUserInterfaceStyle = .light
        switch mode {
        case .dark:
            themingService?.activateDarkTheme()
            userInterfaceStyle = .dark
        case .light:
            themingService?.activateDefaultTheme()
            userInterfaceStyle = .light
        default:
            if UIScreen.main.traitCollection.userInterfaceStyle == .dark {
                themingService?.activateDarkTheme()
            } else {
                themingService?.activateDefaultTheme()
            }
            userInterfaceStyle = UIScreen.main.traitCollection.userInterfaceStyle
        }
        if #available(iOS 13.0, *) {
            UIApplication.shared.windows[0].overrideUserInterfaceStyle = userInterfaceStyle
        }
    }

    class func get() -> ThemeModeType {
        return ThemeModeType(rawValue: UserDefaults.standard.value(forKey: kSaveThemeMode) as? String ?? "Auto") ?? .auto
    }
}
