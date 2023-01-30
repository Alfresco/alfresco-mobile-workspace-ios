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

class TaskCommentTableCellViewModel: RowViewModel {
    
    var userID: Int?
    var userName: String?
    var commentID: Int?
    var comment: String?
    var dateString: String?
    var isShowReadMore = false
    var didSelectCommentAction: (() -> Void)?

    func cellIdentifier() -> String {
        return "TaskCommentTableViewCell"
    }
    
    init(userID: Int?,
         userName: String?,
         commentID: Int?,
         comment: String?,
         dateString: String?,
         isShowReadMore: Bool = false) {
        
        self.userID = userID
        self.userName = userName
        self.commentID = commentID
        self.comment = comment
        self.dateString = dateString
        self.isShowReadMore = isShowReadMore
    }
    
    var commentUserName: String? {
        let apsUserID = UserProfile.apsUserID
        if apsUserID == userID {
            return LocalizationConstants.EditTask.meTitle
        } else {
            return userName
        }
    }
}
