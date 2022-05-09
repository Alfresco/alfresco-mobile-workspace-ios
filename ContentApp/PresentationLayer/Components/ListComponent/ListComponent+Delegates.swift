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
import AlfrescoContent

protocol ListItemActionDelegate: AnyObject {
    func showPreview(for node: ListNode,
                     from model: ListComponentModelProtocol)
    func showActionSheetForListItem(for node: ListNode,
                                    from model: ListComponentModelProtocol,
                                    delegate: NodeActionsViewModelDelegate)
    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate)
    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?)
    func showCamera()
    func showPhotoLibrary()
    func showFiles()
    func showUploadingFiles()
    func moveNodeTapped(for sourceNode: ListNode,
                        destinationNode: ListNode,
                        delegate: NodeActionsViewModelDelegate,
                        actionMenu: ActionMenu)
    func renameNodeForListItem(for node: ListNode?, actionMenu: ActionMenu,
                               delegate: CreateNodeViewModelDelegate?)
}

protocol ListComponentActionDelegate: AnyObject {
    func elementTapped(node: ListNode)
    func didUpdateList(in listComponentViewController: ListComponentViewController,
                       error: Error?,
                       pagination: Pagination?)

    func performListAction()
}

extension ListItemActionDelegate {
    func showNodeCreationSheet(delegate: NodeActionsViewModelDelegate) {
        // Do nothing
    }

    func showNodeCreationDialog(with actionMenu: ActionMenu,
                                delegate: CreateNodeViewModelDelegate?) {
        // Do nothing
    }
    
    func showCamera() {
        // Do nothing
    }
    
    func showPhotoLibrary() {
        // Do nothing
    }
    
    func showFiles() {
        // Do nothing
    }
    
    func showUploadingFiles() {
        // Do nothing
    }
}
