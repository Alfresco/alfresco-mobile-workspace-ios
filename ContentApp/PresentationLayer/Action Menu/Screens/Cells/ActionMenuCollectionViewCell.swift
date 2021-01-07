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

class ActionMenuCollectionViewCell: ListSelectableCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var separator: UIView!
    @IBOutlet weak var sectionSeparator: UIView!

    var action: ActionMenu? {
        didSet {
            imageView.image = action?.icon
            titleLabel.text = action?.title
            isUserInteractionEnabled = !(action?.type == .node)
            separator.isHidden = !(action?.type == .node)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        sectionSeparator.isHidden = true
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        titleLabel.applyStyleBody1OnSurface(theme: currentTheme)
        titleLabel.lineBreakMode = .byTruncatingTail
        imageView.tintColor = currentTheme.onSurfaceColor
        separator.backgroundColor = currentTheme.onSurface15Color
        sectionSeparator.backgroundColor = currentTheme.onSurface15Color
    }
}
