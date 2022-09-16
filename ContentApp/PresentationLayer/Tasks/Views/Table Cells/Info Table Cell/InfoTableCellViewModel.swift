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

class InfoTableCellViewModel: RowViewModel {

    var imageName: String?
    var title: String?
    var value: String?
    var isHideDivider = true
    var isEditMode = false
    var isHideEditImage: Bool {
        return !isEditMode
    }
    var didSelectEditInfo: (() -> Void)?
    var didSelectValue: (() -> Void)?

    func cellIdentifier() -> String {
        return "InfoTableViewCell"
    }
    
    init(imageName: String?,
         title: String?,
         value: String?,
         isHideDivider: Bool = true,
         isEditMode: Bool) {
        self.imageName = imageName
        self.title = title
        self.value = value
        self.isHideDivider = isHideDivider
        self.isEditMode = isEditMode
    }
    
    var image: UIImage? {
        if let name = imageName, let image =  UIImage(named: name) {
            return image
        }
        return nil
    }
}
