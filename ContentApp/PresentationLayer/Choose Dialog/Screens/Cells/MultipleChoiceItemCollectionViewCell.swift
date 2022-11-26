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

class MultipleChoiceItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var item: MultipleChoiceItem? {
        didSet {
            if let item = item {
                titleLabel.text = item.title
                iconImageView.image = (item.selected) ?
                    UIImage(named: "ic-radio-checked") :
                    UIImage(named: "ic-radio-unchecked")
                setAccessibility(item: item)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        titleLabel.applyStyleBody1OnSurface(theme: currentTheme)
        iconImageView.tintColor = currentTheme.onSurfaceColor
    }
    
    private func setAccessibility(item: MultipleChoiceItem) {
        titleLabel.accessibilityLabel = titleLabel.text
        titleLabel.accessibilityValue = item.selected ? LocalizationConstants.Accessibility.selected:""
        titleLabel.accessibilityTraits = .button
    }
}
