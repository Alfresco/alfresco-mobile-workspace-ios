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
        
        let actionCreateFolder = ActionMenu(title: LocalizationConstants.ActionMenu.createFolder,
                                            type: .createFolder)
        let actionScanDocuments = ActionMenu(title: LocalizationConstants.ActionMenu.scanDocuments,
                                            type: .scanDocuments)
        var actionCreateMedia = ActionMenu(title: LocalizationConstants.ActionMenu.createMedia,
                                           type: .createMedia)
        var actionUploadMedia = ActionMenu(title: LocalizationConstants.ActionMenu.uploadMedia,
                                           type: .uploadMedia)
        let actionUploadFiles = ActionMenu(title: LocalizationConstants.ActionMenu.uploadFiles,
                                            type: .uploadFiles)
       
        if !ConfigurationManager.shared.isPaidUser() {
            actionUploadMedia = ActionMenu(title: LocalizationConstants.ActionMenu.uploadSingleMedia,
                                           type: .uploadMedia)
            actionCreateMedia = ActionMenu(title: LocalizationConstants.ActionMenu.createSingleMedia,
                                           type: .createMedia)
        }
        
        var actionMenus = [actionCreateFolder,
                        actionCreateMedia,
                        actionUploadMedia,
                        actionUploadFiles
                        ]
        
        if ConfigurationManager.shared.isPaidUser() {
            actionMenus.insert(actionScanDocuments, at: 1)
        }
        actions.append(actionMenus)
        return actions
    }
}
