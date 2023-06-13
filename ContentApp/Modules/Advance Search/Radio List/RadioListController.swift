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

import UIKit
import AlfrescoContent

class RadioListController: NSObject {
    let viewModel: RadioListViewViewModel

    init(viewModel: RadioListViewViewModel = RadioListViewViewModel()) {
        self.viewModel = viewModel
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is ListItemCellViewModel:
            return ListItemTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rows = [RowViewModel]()
        for option in viewModel.radioListOptions {
            var isSelected = false
            if option.optionId == viewModel.selectedRadioListOption?.optionId {
                isSelected = true
            }
            
            let rowVM = ListItemCellViewModel(title: option.name, isRadioList: true, isSelected: isSelected)
            rowVM.didSelectListItem = {
                self.viewModel.selectedRadioListOption = option
                self.buildViewModel()
            }
            rows.append(rowVM)
        }
        viewModel.rowViewModels.value = rows
    }
}
