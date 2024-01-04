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
    var service: MaterialDesignThemingService?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        textField.isAccessibilityElement = true
        textField.delegate = self
    }

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? SingleLineTextTableCellViewModel else { return }
        self.viewModel = viewModel
            
        if viewModel.maxLength > 0 {
            textField.maxLength = viewModel.maxLength
        }
        textField.text = viewModel.text
        textField.label.text = viewModel.name
        textField.placeholder = viewModel.placeholder
        textField.keyboardType = viewModel.keyboardType
        textField.leadingViewMode = .always
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
        guard let currentTheme = service?.activeTheme else { return }
       
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        textField.trailingViewMode = .unlessEditing
        applyTextFieldComponentTheme()
        textField.leadingView = leadingView()
    }
    
    private func leadingView() -> UILabel? {
        if let currency = viewModel?.currencyForAmount, let currentTheme = service?.activeTheme {
            var label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 50))
            label.text = currency
            label.applyStyleSubtitle2OnSurface60(theme: currentTheme)
            return label
        }
        return nil
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

// MARK: - UITextField Delegate
extension SingleLineTextTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let viewModel = self.viewModel else { return false }
        
        let newText = (textField.text as? NSString)?.replacingCharacters(in: range, with: string) ?? ""
        viewModel.checkForErrorMessages(for: newText)
        applyTextFieldComponentTheme()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        guard let viewModel = self.viewModel else { return true }
        viewModel.checkForErrorMessages(for: "")
        applyTextFieldComponentTheme()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
