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

class ThemeModeDialogViewModel: MultipleChoiceViewModelProtocol {

    weak var multipleChoiceViewModelDelegate: MultipleChoiceViewModelDelegate?
    var titleDialog = LocalizationConstants.Theme.theme
    var dialogType = MultipleChoiceDialogType.theme
    var items: [MultipleChoiceItem]
    var themingService: MaterialDesignThemingService?

    init(with themingService: MaterialDesignThemingService?) {
        self.themingService = themingService

        let systemItem = MultipleChoiceItem(guid: 0, title: LocalizationConstants.Theme.auto)
        let darkItem = MultipleChoiceItem(guid: 1, title: LocalizationConstants.Theme.dark)
        let lightItem = MultipleChoiceItem(guid: 2, title: LocalizationConstants.Theme.light)

        guard let theme = themingService?.getThemeMode() else {
            self.items = [systemItem, darkItem, lightItem]
            return
        }
        switch theme {
        case .auto: systemItem.selected = true
        case .dark: darkItem.selected = true
        case .light: lightItem.selected = true
        }
        self.items = [systemItem, darkItem, lightItem]
    }

    func perfomAction(for item: MultipleChoiceItem, completion: @escaping (() -> Void)) {
        switch item.guid {
        case 0: themingService?.saveTheme(mode: ThemeModeType.auto)
        case 1: themingService?.saveTheme(mode: ThemeModeType.dark)
        case 2: themingService?.saveTheme(mode: ThemeModeType.light)
        default: break
        }
        completion()
    }
}
