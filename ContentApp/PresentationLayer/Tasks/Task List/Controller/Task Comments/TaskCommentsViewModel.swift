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

import Foundation
import UIKit

class TaskCommentsViewModel: TaskPropertiesViewModel {
    let rowViewModels = Observable<[RowViewModel]>([])
    var isShowKeyboard = false
    var keyboardShown = false
    var keyboardHeight: CGFloat = 0
    var isAddComment = false
    var commentsCount: String? {
        if comments.value.count > 1 {
            return String(format: LocalizationConstants.Tasks.multipleCommentTitle, comments.value.count)
        }
        return nil
    }

    func isAddCommentAllowed(for message: String?) -> (isAllowed: Bool, message: String) {
        let text = (message ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return (false, text)
        } else {
            return (true, text)
        }
    }
    
    func isScrollAllowed(numberOfRows: Int) -> Bool {
        if !rowViewModels.value.isEmpty && numberOfRows >= rowViewModels.value.count {
            return true
        }
        return false
    }
}
