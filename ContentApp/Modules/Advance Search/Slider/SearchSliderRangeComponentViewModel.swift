//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

class SearchSliderRangeComponentViewModel: NSObject {
    var selectedCategory: SearchCategories?
    var queryBuilder: String?

    var title: String {
        return selectedCategory?.name ?? ""
    }
    
    var step: CGFloat {
        return CGFloat(selectedCategory?.component?.settings?.step ?? 1)
    }
    
    var min: CGFloat {
        return CGFloat(selectedCategory?.component?.settings?.min ?? 0)
    }
    
    var max: CGFloat {
        return CGFloat(selectedCategory?.component?.settings?.max ?? 0)
    }
    
    var numberOfDiscreteValues: UInt {
       return UInt(max - min) + 1
    }
    
    var value: CGFloat {
        if let selectedValue = self.selectedCategory?.component?.settings?.selectedValue {
            return selectedValue.CGFloatValue() ?? min
        }
        return min
    }
    
    ///  To reset filter, pass 0 else pass value
    func applyFilter(with value: CGFloat) {
        if let selectedCategory = self.selectedCategory {
            let component = selectedCategory.component
            let settings = component?.settings
            if value == 0 {
                settings?.selectedValue = ""
            } else {
                settings?.selectedValue = "\(Int(value))"
            }
            component?.settings = settings
            selectedCategory.component = component
            self.selectedCategory = selectedCategory
        }
    }
}
