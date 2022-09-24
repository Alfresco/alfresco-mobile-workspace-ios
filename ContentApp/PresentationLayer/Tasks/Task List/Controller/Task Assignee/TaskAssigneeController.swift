//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

class TaskAssigneeController: NSObject {
    let viewModel: TaskAssigneeViewModel
    var currentTheme: PresentationTheme?
    var didSelectUserAction: (() -> Void)?

    init(viewModel: TaskAssigneeViewModel = TaskAssigneeViewModel(), currentTheme: PresentationTheme?) {
        self.viewModel = viewModel
        self.currentTheme = currentTheme
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is TaskAssigneeTableCellViewModel:
            return TaskAssigneeTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }

    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        
        if let meCell = meCellVM() {
            rowViewModels.append(meCell)
        }
        
        rowViewModels.append(otherCellVM())
        
        if let meCell = meCellVM() {
            rowViewModels.append(meCell)
        }
        
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    // MARK: - Me Table Cell
    private func meCellVM() -> TaskAssigneeTableCellViewModel? {
        if let apsUserID = UserProfile.apsUserID {
            let name = LocalizationConstants.EditTask.meTitle
            let rowVM = TaskAssigneeTableCellViewModel(userID: apsUserID, firstName: name, lastName: nil)
            rowVM.didSelectUserAction = {
                AlfrescoLog.debug("did select user with id \(apsUserID)")
            }
            return rowVM
        }
        return nil
    }
    
    private func otherCellVM() -> TaskAssigneeTableCellViewModel {
        let name = "Ankit Goyal"
        let rowVM = TaskAssigneeTableCellViewModel(userID: 10, firstName: name, lastName: nil)
        rowVM.didSelectUserAction = {
            AlfrescoLog.debug("did select user with id")
        }
        return rowVM
    }
}
