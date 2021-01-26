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
    func emptyList() -> EmptyListProtocol

    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    func refreshList()

    func listNode(for indexPath: IndexPath) -> ListNode
    func titleForSectionHeader(at indexPath: IndexPath) -> String
    func listActionTitle() -> String?

    func shouldDisplaySections() -> Bool
    func shouldDisplayListLoadingIndicator() -> Bool
    func shouldDisplayCreateButton() -> Bool
    func shouldDisplayNodePath() -> Bool
    func shouldDisplayListActionButton() -> Bool
    func shouldEnableListActionButton() -> Bool
    func shouldPreview(node: ListNode) -> Bool
}

extension ListComponentDataSourceProtocol {

    func shouldDisplaySections() -> Bool {
        return false
    }

    func shouldDisplayCreateButton() -> Bool {
        return false
    }

    func shouldDisplayListActionButton() -> Bool {
        return false
    }

    func shouldEnableListActionButton() -> Bool {
        return false
    }

    func shouldDisplayNodePath() -> Bool {
        true
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return false
    }

    func shouldPreview(node: ListNode) -> Bool {
        return true
    }

    func listActionTitle() -> String? {
        return nil
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }
}
