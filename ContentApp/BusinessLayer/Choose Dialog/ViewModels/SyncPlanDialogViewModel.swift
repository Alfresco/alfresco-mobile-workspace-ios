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

class SyncPlanDialogViewModel: ChooseDialogViewModelProtocol {

    weak var chooseDialogDelegate: ChooseDialogViewModelDelegate?
    var titleDialog = LocalizationConstants.Settings.syncDataPlanTitle
    var questionType = ChooseQuestionType.syncPlanData
    var items: [ChooseItem]

    init() {
        let onlyWifiItem = ChooseItem(guid: 0, title: LocalizationConstants.Settings.syncOnlyWifi)
        let allItem = ChooseItem(guid: 1, title: LocalizationConstants.Settings.syncWifiAndCellularData)

        if UserProfile.getOptionToSyncOverCellularData() == true {
            allItem.selected = true
        } else {
            onlyWifiItem.selected = true
        }

        self.items = [onlyWifiItem, allItem]
    }

    func perfomAction(for item: ChooseItem, completion: @escaping (() -> Void)) {
        switch item.guid {
        case 0: UserProfile.persistOptionToSyncOverCellularData(false)
        case 1: UserProfile.persistOptionToSyncOverCellularData(true)
        default: UserProfile.persistOptionToSyncOverCellularData(false)
        }
        completion()
    }
}
