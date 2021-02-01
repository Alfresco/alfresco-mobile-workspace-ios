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

class SyncOverMobileDataDialogViewModel: ChooseDialogViewModelProtocol {

    weak var chooseDialogDelegate: ChooseDialogViewModelDelegate?
    var titleDialog = LocalizationConstants.Settings.syncOverMobileDataTitle
    var questionType = ChooseQuestionType.syncOverMobileData
    var items: [ChooseItem]

    init() {
        let onItem = ChooseItem(guid: 0, title: LocalizationConstants.General.on)
        let offItem = ChooseItem(guid: 1, title: LocalizationConstants.General.off)

        if UserProfile.getOptionToSyncOverMobileData() == true {
            onItem.selected = true
        } else {
            offItem.selected = true
        }

        self.items = [onItem, offItem]
    }

    func perfomAction(for item: ChooseItem, completion: @escaping (() -> Void)) {
        switch item.guid {
        case 0: UserProfile.persistOptionToSyncOverMobileData(true)
        default: UserProfile.persistOptionToSyncOverMobileData(false)
        }
        completion()
    }
}
