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

class TaskCommentsController: NSObject {
    let viewModel: TaskCommentsViewModel
    var currentTheme: PresentationTheme?

    init(viewModel: TaskCommentsViewModel = TaskCommentsViewModel(), currentTheme: PresentationTheme?) {
        self.viewModel = viewModel
        self.currentTheme = currentTheme
    }
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is TaskCommentTableCellViewModel:
            return TaskCommentTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
       
        let comments = commentsCellVM(for: viewModel.comments.value)
        rowViewModels.append(contentsOf: comments)
        self.viewModel.rowViewModels.value = rowViewModels
    }
    
    func updateViewModel(for comments: [TaskCommentModel]) {
        let taskComments = commentsCellVM(for: comments)
        self.viewModel.rowViewModels.value.append(contentsOf: taskComments)
    }
    
    private func commentsCellVM(for comments: [TaskCommentModel]) -> [RowViewModel] {
        var rowVMs = [RowViewModel]()
        if !comments.isEmpty {
            for comment in comments {
                let rowVM = TaskCommentTableCellViewModel(userID: comment.createdBy?.assigneeID,
                                                          userName: comment.createdBy?.userName,
                                                          commentID: comment.commentID,
                                                          comment: comment.message,
                                                          dateString: comment.messageDate,
                                                          isShowReadMore: false)
                rowVMs.append(rowVM)
            }
        }

        return rowVMs
    }
}
