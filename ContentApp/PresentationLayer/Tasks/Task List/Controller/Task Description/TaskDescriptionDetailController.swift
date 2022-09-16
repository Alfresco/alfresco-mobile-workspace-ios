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

class TaskDescriptionDetailController: NSObject {
    let viewModel: TaskDescriptionDetailViewModel
    var currentTheme: PresentationTheme?

    init(viewModel: TaskDescriptionDetailViewModel = TaskDescriptionDetailViewModel(), currentTheme: PresentationTheme?) {
        self.viewModel = viewModel
        self.currentTheme = currentTheme
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is TitleTableCellViewModel:
            return TitleTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        rowViewModels.append(titleCellVM())
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    // MARK: - Title
    private func titleCellVM() -> TitleTableCellViewModel {
        var taskDescription = viewModel.taskDescription ?? ""
        if taskDescription.isEmpty {
            taskDescription = LocalizationConstants.Tasks.noDescription
        }

        let rowVM = TitleTableCellViewModel(title: viewModel.taskName,
                                            subTitle: taskDescription,
                                            isHideReadMore: true,
                                            isEditMode: false)
        return rowVM
    }
}
