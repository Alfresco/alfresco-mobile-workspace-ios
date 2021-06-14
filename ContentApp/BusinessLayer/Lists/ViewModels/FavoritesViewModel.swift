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

class FavoritesViewModel: ListComponentViewModel {

    override func emptyList() -> EmptyListProtocol {
        if let model = model as? FavoritesModel {
            if model.listCondition == APIConstants.QuerryConditions.whereFavoritesFileFolder {
                return EmptyFavoritesFilesFolders()
            }
        }

        return EmptyFavoritesLibraries()
    }

    override func shouldDisplaySettingsButton() -> Bool {
        return true
    }

    override func shouldDisplaySubtitle(for indexPath: IndexPath) -> Bool {
        if let model = model as? FavoritesModel {
            return model.listCondition == APIConstants.QuerryConditions.whereFavoritesFileFolder
        }

        return false
    }
}
