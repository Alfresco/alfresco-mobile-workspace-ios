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
    var didSelectUserAction: ((_ user: TaskNodeAssignee) -> Void)?

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
        
        rowViewModels.append(contentsOf: searchedUsersCellVM())
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    // MARK: - Me Table Cell
    private func meCellVM() -> TaskAssigneeTableCellViewModel? {
        if let apsUserID = UserProfile.apsUserID {
            let name = LocalizationConstants.EditTask.meTitle
            let rowVM = TaskAssigneeTableCellViewModel(userID: apsUserID, firstName: name, lastName: nil)
            rowVM.didSelectUserAction = {[weak self] in
                guard let sSelf = self else { return }
                sSelf.didSelectUserAction?(sSelf.loggedInUser())
            }
            return rowVM
        }
        return nil
    }
    
    private func loggedInUser() -> TaskNodeAssignee {
        let apsUserID = UserProfile.apsUserID ?? -1
        let user = TaskNodeAssignee(assigneeID: apsUserID, firstName: UserProfile.firstName, lastName: UserProfile.lastName, email: UserProfile.email)
        return user
    }
    
    private func searchedUsersCellVM() -> [RowViewModel] {
        var rowVMs = [RowViewModel]()
        let apsUserID = UserProfile.apsUserID ?? -1
        let searchedUsers = viewModel.users.value
        for user in searchedUsers where user.assigneeID != apsUserID {
            let rowVM = TaskAssigneeTableCellViewModel(userID: user.assigneeID, firstName: user.firstName, lastName: user.lastName)
            rowVM.didSelectUserAction = { [weak self] in
                guard let sSelf = self else { return }
                sSelf.didSelectUserAction?(user)
            }
            rowVMs.append(rowVM)
        }
        return rowVMs
    }
}
