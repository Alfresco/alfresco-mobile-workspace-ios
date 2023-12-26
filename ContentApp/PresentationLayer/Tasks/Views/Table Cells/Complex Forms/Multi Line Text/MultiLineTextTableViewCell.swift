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

class MultiLineTextTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var textArea: MDCOutlinedTextArea!    
    var viewModel: MultiLineTextTableCellViewModel?
    var activeTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        textArea.isAccessibilityElement = true
    }

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? MultiLineTextTableCellViewModel else { return }
        self.viewModel = viewModel
        
        textArea.textView.text = viewModel.text
        textArea.label.text = viewModel.title
        textArea.placeholder = viewModel.placeholder
        textArea.sizeToFit()
        addAccessibility()
    }
    
    private func addAccessibility() {
        textArea.accessibilityTraits = .staticText
        textArea.accessibilityIdentifier = "sub-title"
        textArea.accessibilityLabel = LocalizationConstants.Accessibility.descriptionTitle
        textArea.accessibilityValue = textArea.textView.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme,
              let textFieldScheme = service?.containerScheming(for: .loginTextField) else { return}
        
        self.activeTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        textArea.applyTheme(withScheme: textFieldScheme)
        textArea.trailingViewMode = .unlessEditing
        textArea.leadingAssistiveLabel.text = ""
        textArea.trailingView = nil
        textArea.maximumNumberOfVisibleRows = 3
    }
}
