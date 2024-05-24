//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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
import MaterialComponents

class CheckBoxTableViewCell: UITableViewCell, CellConfigurable, CellThemeApplier {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var selectionButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    
    var viewModel: CheckBoxTableViewCellViewModel?
    var service: MaterialDesignThemingService?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        checkBoxImageView.isAccessibilityElement = true
        titleLabel.isAccessibilityElement = true
        selectionButton.isAccessibilityElement = true
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? CheckBoxTableViewCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.name
        self.checkBoxImageView.image = viewModel.image
        viewAllButton.isHidden = isViewAllButtonHidden(label: titleLabel)
        addAccessibility()
    }
    private func isViewAllButtonHidden(label: UILabel) -> Bool {
        // Calculate the size of the text using boundingRect
        let maxSize = CGSize(width: label.bounds.width, height: .greatestFiniteMagnitude)
        let textSize = (label.text ?? "").boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: label.font!], context: nil).size

        // Compare the calculated text size with the intrinsic content size
        if textSize.height > label.intrinsicContentSize.height {
            // Your text is greater than the label size
            return false
        } else {
            // Text fits within two lines
            return true
        }
    }
    
    private func addAccessibility() {
        titleLabel.accessibilityTraits = .staticText
        titleLabel.accessibilityIdentifier = titleLabel.text
        titleLabel.accessibilityLabel = titleLabel.text
        titleLabel.accessibilityValue = titleLabel.text
        
        selectionButton.accessibilityLabel = self.titleLabel.text
        selectionButton.accessibilityHint = LocalizationConstants.Accessibility.listOption
        selectionButton.accessibilityValue = "\(String(describing: self.viewModel?.isSelected))"
        selectionButton.accessibilityIdentifier = "list-option"
        
        titleLabel.accessibilityIdentifier = "\(String(describing: self.titleLabel.text))"
        checkBoxImageView.accessibilityIdentifier = "\(String(describing: self.titleLabel.text))"
    }
    
    func applyCellTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
       
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        checkBoxImageView.tintColor = currentTheme.onSurface70Color
    }
}
