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

class TaskAssigneeTableCellViewModel: RowViewModel {
    
    var userID: Int?
    var firstName: String?
    var lastName: String?
    var userName: String?
    var didSelectUserAction: (() -> Void)?
    var groupName: String?

    func cellIdentifier() -> String {
        return "TaskAssigneeTableViewCell"
    }
    
    init(userID: Int?,
         firstName: String?,
         lastName: String?,
         groupName: String?) {
        
        let fName = firstName ?? ""
        let lName = lastName ?? ""
        self.userID = userID
        self.firstName = fName
        self.lastName = lName
        self.userName = String(format: "%@ %@", fName, lName).trimmingCharacters(in: .whitespacesAndNewlines)
        self.groupName = groupName
    }
    
    func displayName() -> String? {
        if let groupName = groupName, !groupName.isEmpty {
            return groupName
        } else {
            return userName
        }
    }
}
