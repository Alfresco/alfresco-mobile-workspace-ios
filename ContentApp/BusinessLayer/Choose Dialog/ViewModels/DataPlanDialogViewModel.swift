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

class DataPlanDialogViewModel: MultipleChoiceViewModelProtocol {

    weak var multipleChoiceViewModelDelegate: MultipleChoiceViewModelDelegate?
    var titleDialog = LocalizationConstants.Settings.syncDataPlanTitle
    var dialogType = MultipleChoiceDialogType.syncPlanData
    var items: [MultipleChoiceItem]

    init() {
        let wifiItem =
            MultipleChoiceItem(guid: 0,
                               title: LocalizationConstants.Settings.syncOnlyWifi)
        let wifiAndCellularDataItem =
            MultipleChoiceItem(guid: 1, title:
                                LocalizationConstants.Settings.syncWifiAndCellularData)

        if UserProfile.allowSyncOverCellularData == true {
            wifiAndCellularDataItem.selected = true
        } else {
            wifiItem.selected = true
        }

        self.items = [wifiItem, wifiAndCellularDataItem]
    }

    func perfomAction(for item: MultipleChoiceItem, completion: @escaping (() -> Void)) {
        switch item.guid {
        case 0: UserProfile.allowSyncOverCellularData = false
        case 1: UserProfile.allowSyncOverCellularData = true
        default: UserProfile.allowSyncOverCellularData = false
        }
        completion()
    }
}
