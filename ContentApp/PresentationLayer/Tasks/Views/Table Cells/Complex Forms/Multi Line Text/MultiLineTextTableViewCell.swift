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

class MultiLineTextTableViewCell: UITableViewCell, CellConfigurable, CellThemeApplier {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var textArea: MDCOutlinedTextArea!    
    var viewModel: MultiLineTextTableCellViewModel?
    var service: MaterialDesignThemingService?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        textArea.isAccessibilityElement = true
        textArea.textView.delegate = self
    }

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? MultiLineTextTableCellViewModel else { return }
        self.viewModel = viewModel
        
        textArea.textView.text = viewModel.text
        textArea.label.text = viewModel.name
        textArea.placeholder = viewModel.placeholder
        textArea.sizeToFit()
        addAccessibility()
    }
    
    private func addAccessibility() {
        textArea.accessibilityTraits = .searchField
        textArea.accessibilityIdentifier = textArea.label.text
        textArea.accessibilityLabel = textArea.label.text
        textArea.accessibilityValue = textArea.textView.text
        textArea.accessibilityHint = textArea.placeholder
    }
    
    func applyCellTheme(with service: MaterialDesignThemingService?) {
        applyTheme(with: service)
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        textArea.backgroundColor = currentTheme.surfaceColor
        textArea.trailingViewMode = .unlessEditing
        textArea.maximumNumberOfVisibleRows = 2
        applyTextViewComponentTheme()
    }
    
    func applyTextViewComponentTheme() {
        guard let textFieldScheme = service?.containerScheming(for: .loginTextField),
              let viewModel = self.viewModel else { return }
        
        let errorMessage = viewModel.errorMessage ?? ""
        if !errorMessage.isEmpty {
            textArea.applyErrorTheme(withScheme: textFieldScheme)
        } else {
            textArea.applyTheme(withScheme: textFieldScheme)
        }
        textArea.leadingAssistiveLabel.text = viewModel.errorMessage
        textArea.trailingView = nil
    }
}

// MARK: - UITextField Delegate
extension MultiLineTextTableViewCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let viewModel = self.viewModel else { return false }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text) 
        viewModel.checkForErrorMessages(for: newText)
        applyTextViewComponentTheme()
        addAccessibility()
        return true
    }
}
