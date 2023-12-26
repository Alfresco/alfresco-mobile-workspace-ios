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
    @IBOutlet weak var textField: MDCOutlinedTextField!
    var viewModel: SingleLineTextTableCellViewModel?
    var activeTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        textField.isAccessibilityElement = true
    }

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? SingleLineTextTableCellViewModel else { return }
        self.viewModel = viewModel
            
        textField.text = viewModel.text
        textField.label.text = viewModel.title
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = viewModel.keyboardType
        addAccessibility()
    }
    
    private func addAccessibility() {
        textField.accessibilityTraits = .staticText
        textField.accessibilityIdentifier = "sub-title"
        textField.accessibilityLabel = LocalizationConstants.Accessibility.descriptionTitle
        textField.accessibilityValue = textField.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme,
              let textFieldScheme = service?.containerScheming(for: .loginTextField) else { return}
       
        self.activeTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        textField.applyTheme(withScheme: textFieldScheme)
        textField.trailingViewMode = .unlessEditing
        textField.leadingAssistiveLabel.text = ""
        textField.trailingView = nil
    }
}
