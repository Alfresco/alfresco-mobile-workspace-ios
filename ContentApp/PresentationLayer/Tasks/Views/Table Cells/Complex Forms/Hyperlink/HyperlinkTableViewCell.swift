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

class HyperlinkTableViewCell: UITableViewCell, CellConfigurable, CellThemeApplier {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var textField: MDCOutlinedTextField!
    @IBOutlet weak var hyperlinkButton: UIButton!
    var viewModel: HyperlinkTableViewCellViewModel?
    var service: MaterialDesignThemingService?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        textField.isAccessibilityElement = true
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? HyperlinkTableViewCellViewModel else { return }
        self.viewModel = viewModel
            
        if viewModel.maxLength > 0 {
            textField.maxLength = viewModel.maxLength
        }
        textField.text = viewModel.displayText
        textField.label.text = viewModel.name
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = viewModel.keyboardType
        textField.leadingViewMode = .always
        textField.leadingView = UIImageView(image: UIImage(named: "ic-hyperlink"))
        textField.isUserInteractionEnabled = !viewModel.readOnly
        hyperlinkButton.setTitle("", for: .normal)
        addAccessibility()
    }
    
    private func addAccessibility() {
        textField.accessibilityTraits = .searchField
        textField.accessibilityIdentifier = textField.label.text
        textField.accessibilityLabel = textField.label.text
        textField.accessibilityHint = textField.placeholder
        textField.accessibilityValue = textField.text
    }
    
    func applyCellTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
       
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        textField.trailingViewMode = .unlessEditing
        applyTextFieldComponentTheme()
    }
    
    func applyTextFieldComponentTheme() {
        guard let textFieldScheme = service?.containerScheming(for: .loginTextField),
              let viewModel = self.viewModel else { return }
        
        let errorMessage = viewModel.errorMessage ?? ""
        if !errorMessage.isEmpty {
            textField.applyErrorTheme(withScheme: textFieldScheme)
        } else {
            textField.applyTheme(withScheme: textFieldScheme)
        }
        textField.leadingAssistiveLabel.text = viewModel.errorMessage
    }
}
