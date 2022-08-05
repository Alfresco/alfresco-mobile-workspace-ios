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

class TaskDetailController: NSObject {
    let viewModel: TaskDetailViewModel

    init(viewModel: TaskDetailViewModel = TaskDetailViewModel()) {
        self.viewModel = viewModel
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is TitleTableCellViewModel:
            return TitleTableViewCell.cellIdentifier()
        case is InfoTableCellViewModel:
            return InfoTableViewCell.cellIdentifier()
        case is PriorityTableCellViewModel:
            return PriorityTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        viewModel.rowViewModels.value = [titleCellVM(),
                                         dueDateCellVM(),
                                         priorityCellVM(),
                                         assignedCellVM(),
                                         statusCellVM(),
                                         identifierCellVM()
        ]
    }
    
    private func titleCellVM() -> TitleTableCellViewModel {
        let rowVM = TitleTableCellViewModel(title: viewModel.name)
        return rowVM
    }

    private func dueDateCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-calendar-icon", title: LocalizationConstants.Accessibility.dueDate, value: viewModel.getDueDate())
        return rowVM
    }
    
    private func priorityCellVM() -> PriorityTableCellViewModel {
        let rowVM = PriorityTableCellViewModel(title: LocalizationConstants.Accessibility.priority, priority: viewModel.priority)
        return rowVM
    }
    
    private func assignedCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-assigned-icon", title: LocalizationConstants.Accessibility.assignee, value: viewModel.assigneeName)
        return rowVM
    }
    
    private func statusCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-status-icon", title: LocalizationConstants.Tasks.status, value: viewModel.status)
        return rowVM
    }
    
    private func identifierCellVM() -> InfoTableCellViewModel {
        let rowVM = InfoTableCellViewModel(imageName: "ic-identifier-icon", title: LocalizationConstants.Tasks.identifier, value: viewModel.taskID)
        return rowVM
    }
}
