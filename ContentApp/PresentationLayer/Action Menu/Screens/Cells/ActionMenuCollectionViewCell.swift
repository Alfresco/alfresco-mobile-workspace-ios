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
    @IBOutlet weak var widthImageView: NSLayoutConstraint!
    @IBOutlet weak var leadingTitleLabel: NSLayoutConstraint!
    var currentTheme: PresentationTheme?

    var action: ActionMenu? {
        didSet {
            DispatchQueue.main.async {[weak self] in
                guard let sSelf = self else { return }
                sSelf.imageView.image = sSelf.action?.icon
                sSelf.titleLabel.text = sSelf.action?.title
                sSelf.isUserInteractionEnabled = !(sSelf.action?.type == .node)
                sSelf.separator.isHidden = !(sSelf.action?.type == .node)
                sSelf.applyAccessibility(action: sSelf.action)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        sectionSeparator.isHidden = true
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        
        titleLabel.applyStyleBody1OnSurface(theme: currentTheme)
        titleLabel.lineBreakMode = .byTruncatingTail
        imageView.tintColor = currentTheme.onSurface70Color
        separator.backgroundColor = currentTheme.dividerColor
        sectionSeparator.backgroundColor = currentTheme.onSurface15Color
    }
    
    func applyAccessibility(action: ActionMenu?) {
        titleLabel.accessibilityLabel = titleLabel.text
        titleLabel.accessibilityIdentifier = action?.analyticEventName
        if isUserInteractionEnabled {
            titleLabel.accessibilityTraits = .button
        } else {
            titleLabel.accessibilityTraits = .header
        }
    }
    
    func setCellHeader(isMultiSelectionHeader: Bool) {
        guard let theme = currentTheme else { return }
        if isMultiSelectionHeader {
            titleLabel.textColor = theme.primaryVariantT1Color
            widthImageView.constant = 0
            leadingTitleLabel.constant = 0
        } else {
            titleLabel.textColor = theme.onSurfaceColor
            widthImageView.constant = 24.0
            leadingTitleLabel.constant = 26.0
        }
    }
}
