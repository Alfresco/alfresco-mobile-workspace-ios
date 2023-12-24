//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

class SingleLineTextTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textBaseView: UIView!
    @IBOutlet weak var textField: UITextField!
    var viewModel: SingleLineTextTableCellViewModel?
    var activeTheme: PresentationTheme?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        textBaseView.isAccessibilityElement = false
        textField.isAccessibilityElement = true
    }

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? SingleLineTextTableCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        textField.text = viewModel.text
        textField.placeholder = viewModel.placeholder
        addAccessibility()
    }
    
    private func addAccessibility() {
        titleLabel.accessibilityTraits = .staticText
        titleLabel.accessibilityIdentifier = "title"
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleLabel.accessibilityValue = titleLabel.text
        
        textField.accessibilityTraits = .staticText
        textField.accessibilityIdentifier = "sub-title"
        textField.accessibilityLabel = LocalizationConstants.Accessibility.descriptionTitle
        textField.accessibilityValue = textField.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
       
        self.activeTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        
        textField.backgroundColor = currentTheme.surfaceColor
        textField.textColor = currentTheme.onSurface70Color
        textField.font = currentTheme.subtitle2TextStyle.font
        
        textBaseView.backgroundColor = currentTheme.surfaceColor
        textBaseView.layer.cornerRadius = 5
        textBaseView.layer.borderWidth = 1
        textBaseView.layer.borderColor = currentTheme.onSurface15Color.cgColor
    }
}
