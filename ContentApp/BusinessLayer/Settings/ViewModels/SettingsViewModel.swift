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

class SettingsViewModel {
    var items: [SettingsItem] = []
    var themingService: MaterialDesignThemingService?

    init(themingService: MaterialDesignThemingService?) {
        self.themingService = themingService
        reload()
    }

    func reload() {
        items = [SettingsItem(type: .account, title: "John Doe", subtitle: "john.doe@alfresco.com", icon: "account-circle")]
        if #available(iOS 13.0, *) {
            items.append(getThemeItem())
        }
    }

    func getThemeItem() -> SettingsItem {
        var themeName = LocalizationConstants.Theme.auto
        switch themingService?.getThemeMode() {
        case .light:
             themeName = LocalizationConstants.Theme.light
        case .dark:
            themeName = LocalizationConstants.Theme.dark
        default:
            themeName = LocalizationConstants.Theme.auto
        }
        return SettingsItem(type: .theme, title: LocalizationConstants.Theme.theme, subtitle: themeName, icon: "theme")
    }
}
