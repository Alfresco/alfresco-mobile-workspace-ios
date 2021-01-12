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
import AlfrescoContent

protocol ListComponentDataSourceProtocol: class {
    func isEmpty() -> Bool
    func shouldDisplaySections() -> Bool
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func listNode(for indexPath: IndexPath) -> ListNode
    func titleForSectionHeader(at indexPath: IndexPath) -> String
    func shouldDisplayListLoadingIndicator() -> Bool
    func shouldDisplayMoreButton() -> Bool
    func shouldDisplayCreateButton() -> Bool
    func shouldDisplayListActionButton() -> Bool
    func listActionTitle() -> String?
    func shouldDisplayNodePath() -> Bool
    func refreshList()
    func emptyList() -> EmptyListProtocol
}

extension ListComponentDataSourceProtocol {
    func shouldDisplayListActionButton() -> Bool {
        return false
    }

    func listActionTitle() -> String? {
        return nil
    }
}
