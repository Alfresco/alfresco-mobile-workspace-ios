//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

class MultipleSelectionModel: NSObject {
    public static let shared = MultipleSelectionModel()
    var isMultipleFileSelection = false
    var multipleSelectedNodes = [ListNode]()
    var multpleSelectedOptionsView = MultipleSelectionOptions.loadFromXib()
    var tabBarScreenCoordinator: TabBarScreenCoordinator?

    func showMultipleFilesSelectionUI() {
        let nodes = MultipleSelectionModel.shared.multipleSelectedNodes
        if nodes.isEmpty {
            multpleSelectedOptionsView.removeFromSuperview()
        } else {
            multpleSelectedOptionsView.removeFromSuperview()
            multpleSelectedOptionsView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 150.0, width: UIScreen.main.bounds.width, height: 50.0)
            let window = UIApplication.shared.windows.last!
            window.addSubview(multpleSelectedOptionsView)
        }
    }
    
    func toggleMultipleSelection() {
        MultipleSelectionModel.shared.isMultipleFileSelection = !MultipleSelectionModel.shared.isMultipleFileSelection
        MultipleSelectionModel.shared.multipleSelectedNodes.removeAll()
        MultipleSelectionModel.shared.showMultipleFilesSelectionUI()
        tabBarScreenCoordinator?.reloadCollectionViews()
    }
}
