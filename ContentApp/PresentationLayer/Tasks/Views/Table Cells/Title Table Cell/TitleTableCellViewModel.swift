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

class TitleTableCellViewModel: RowViewModel {
    var title: String?
    var subTitle: String?
    var isHideReadMore = false
    var isViewAllButtonVisible = false
    var didSelectReadMoreAction: (() -> Void)?
    var didSelectEditTitle: (() -> Void)?
    var isEditMode = false
    var isHideEditImage: Bool {
        return !isEditMode
    }

    var widthEditImageView: CGFloat {
        if isEditMode {
            return 40.0
        }
        return 0.0
    }
    
    func cellIdentifier() -> String {
        return "TitleTableViewCell"
    }
    
    init(title: String?,
         subTitle: String?,
         isHideReadMore: Bool = false,
         isEditMode: Bool) {
        self.title = title
        self.subTitle = subTitle
        self.isHideReadMore = isHideReadMore
        self.isEditMode = isEditMode
    }
}
