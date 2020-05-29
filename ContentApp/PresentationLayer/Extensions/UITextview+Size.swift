//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

extension UITextView {
    func calculatedContentSize() -> CGSize {
        var contentSize = self.bounds.size
        let contentInsets = self.contentInset
        let containerInsets = self.textContainerInset
        var maxWidth = contentSize.width
        maxWidth -= 2.0 * self.textContainer.lineFragmentPadding
        maxWidth -= contentInsets.left + contentInsets.right + containerInsets.left + containerInsets.right

        let selectable = self.isSelectable
        self.isSelectable = true

        let textSize = self.attributedText.boundingRect(with: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude), options: [.usesLineFragmentOrigin, .usesFontLeading] , context: nil).size
        self.isSelectable = selectable

        contentSize.height = CGFloat(ceilf(Float(textSize.height)))
        contentSize.height += contentInsets.top + contentInsets.bottom + containerInsets.top + containerInsets.bottom

        return contentSize
    }
}
