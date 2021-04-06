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

struct ActionsMenuCreateFAB {
    static func actions() -> [[ActionMenu]] {
        var actions = [[ActionMenu]]()

        let actions1 = [ActionMenu(title: LocalizationConstants.ActionMenu.createFolder,
                                   type: .createFolder),
                        ActionMenu(title: LocalizationConstants.ActionMenu.createMedia,
                                                   type: .createMedia),
                        ActionMenu(title: LocalizationConstants.ActionMenu.createMSword,
                                   type: .createMSWord),
                        ActionMenu(title: LocalizationConstants.ActionMenu.createMSpowerpoint,
                                   type: .createMSPowerPoint),
                        ActionMenu(title: LocalizationConstants.ActionMenu.createMSexcel,
                                   type: .createMSExcel)]
        actions.append(actions1)
        return actions
    }
}
