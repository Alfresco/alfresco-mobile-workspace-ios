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
import AlfrescoAuth
import AlfrescoContent

class FolderDrillViewModel: ListComponentViewModel {
    override func shouldDisplayCreateButton() -> Bool {
        guard let model = model as? FolderDrillModel,
              let listNode = model.listNode else { return true }
        return listNode.hasPermissionToCreate()
    }

    override func shouldDisplayMoreButton(for indexPath: IndexPath) -> Bool {
        switch model.syncStatusForNode(at: indexPath) {
        case .pending:
            return false
        case .inProgress:
            return false
        case .error:
            return false
        default:
            return true
        }
    }
}
