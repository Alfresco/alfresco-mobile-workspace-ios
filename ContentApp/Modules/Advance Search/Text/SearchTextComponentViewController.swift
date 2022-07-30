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
import AlfrescoContent
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class SearchTextComponentViewController: SystemThemableViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var keywordTextField: MDCOutlinedTextField!
    @IBOutlet weak var dividerTextField: UIView!
    @IBOutlet weak var applyButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    lazy var textViewModel = SearchTextComponentViewModel()
    var callback: SearchComponentCallBack?
    var taskFilterCallBack: TaskFilterCallBack?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        baseView.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        hideKeyboardWhenTappedAround()
        applyLocalization()
        applyComponentsThemes()
        keywordTextField.becomeFirstResponder()
        applyButton.accessibilityIdentifier = "applyActionButton-textComponent"
        resetButton.accessibilityIdentifier = "resetActionButton-textComponent"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        view.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }
    
    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
    }
    
    // MARK: - Apply Themes and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let textFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
              let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        headerTitleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        dismissButton.tintColor = currentTheme.onSurfaceColor
        divider.backgroundColor = currentTheme.onSurface12Color
        dividerTextField.backgroundColor = currentTheme.onSurface12Color
        
        keywordTextField.applyTheme(withScheme: textFieldScheme)
        keywordTextField.trailingViewMode = .unlessEditing
        keywordTextField.leadingAssistiveLabel.text = ""
        keywordTextField.trailingView = nil
        
        applyButton.applyContainedTheme(withScheme: buttonScheme)
        applyButton.isUppercaseTitle = false
        applyButton.setShadowColor(.clear, for: .normal)
        applyButton.layer.cornerRadius = UIConstants.cornerRadiusDialog

        resetButton.applyContainedTheme(withScheme: bigButtonScheme)
        resetButton.setBackgroundColor(currentTheme.onSurface5Color, for: .normal)
        resetButton.isUppercaseTitle = false
        resetButton.setShadowColor(.clear, for: .normal)
        resetButton.setTitleColor(currentTheme.onSurfaceColor, for: .normal)
        resetButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
    }
    
    private func applyLocalization() {
        let placeholder = self.textViewModel.getPlaceholder()
        let value = self.textViewModel.getValue()
        headerTitleLabel.text = textViewModel.title
        keywordTextField.label.text = placeholder
        keywordTextField.text = value
        applyButton.setTitle(LocalizationConstants.AdvanceSearch.apply, for: .normal)
        resetButton.setTitle(LocalizationConstants.AdvanceSearch.reset, for: .normal)
    }
    
    @IBAction func dismissComponentButtonAction(_ sender: Any) {
        if textViewModel.isTaskFilter {
            self.taskFilterCallBack?(self.textViewModel.taskChip, true)
        } else {
            self.callback?(self.textViewModel.selectedCategory, self.textViewModel.queryBuilder, true)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        let text = (self.keywordTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            self.textViewModel.applyFilter(with: nil)
        } else {
            self.textViewModel.applyFilter(with: text)
        }
        
        if textViewModel.isTaskFilter {
            self.taskFilterCallBack?(self.textViewModel.taskChip, false)
        } else {
            self.callback?(self.textViewModel.selectedCategory, self.textViewModel.queryBuilder, false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        self.textViewModel.applyFilter(with: nil)
        if textViewModel.isTaskFilter {
            self.taskFilterCallBack?(self.textViewModel.taskChip, false)
        } else {
            self.callback?(self.textViewModel.selectedCategory, self.textViewModel.queryBuilder, false)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
}

// MARK: - Storyboard Instantiable
extension SearchTextComponentViewController: SearchComponentsStoryboardInstantiable { }

