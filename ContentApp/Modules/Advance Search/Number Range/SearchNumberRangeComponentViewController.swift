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

class SearchNumberRangeComponentViewController: SystemThemableViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var minRangeTextField: MDCOutlinedTextField!
    @IBOutlet weak var maxRangeTextField: MDCOutlinedTextField!
    @IBOutlet weak var horizontalDivider: UIView!
    @IBOutlet weak var dividerTextField: UIView!
    @IBOutlet weak var applyButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    @IBOutlet weak var errorLabel: UILabel!
    lazy var numberRangeViewModel = SearchNumberRangeComponentViewModel()
    var callback: SearchComponentCallBack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        baseView.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        hideKeyboardWhenTappedAround()
        applyLocalization()
        applyComponentsThemes()
        minRangeTextField.becomeFirstResponder()
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
        horizontalDivider.backgroundColor = currentTheme.onSurface12Color
        dividerTextField.backgroundColor = currentTheme.onSurface12Color
        errorLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        errorLabel.textColor = currentTheme.errorColor
        
        minRangeTextField.applyTheme(withScheme: textFieldScheme)
        minRangeTextField.trailingViewMode = .unlessEditing
        minRangeTextField.leadingAssistiveLabel.text = ""
        minRangeTextField.trailingView = nil
        
        maxRangeTextField.applyTheme(withScheme: textFieldScheme)
        maxRangeTextField.trailingViewMode = .unlessEditing
        maxRangeTextField.leadingAssistiveLabel.text = ""
        maxRangeTextField.trailingView = nil
        
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
        let minValue = numberRangeViewModel.getPrefilledValues().minValue
        let maxValue = numberRangeViewModel.getPrefilledValues().maxValue
        headerTitleLabel.text = numberRangeViewModel.title
        minRangeTextField.label.text = LocalizationConstants.AdvanceSearch.fromKeyword
        maxRangeTextField.label.text = LocalizationConstants.AdvanceSearch.toKeyword
        minRangeTextField.text = minValue
        maxRangeTextField.text = maxValue
        checkForError(for: minValue, and: maxValue)
        applyButton.setTitle(LocalizationConstants.AdvanceSearch.apply, for: .normal)
        resetButton.setTitle(LocalizationConstants.AdvanceSearch.reset, for: .normal)
    }
    
    @IBAction func dismissComponentButtonAction(_ sender: Any) {
        self.callback?(self.numberRangeViewModel.selectedCategory, self.numberRangeViewModel.queryBuilder, true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        if numberRangeViewModel.isValidationPassed(minValue: minRangeTextField.text, maxValue: maxRangeTextField.text) {
            numberRangeViewModel.applyFilter(minValue: minRangeTextField.text, maxValue: maxRangeTextField.text)
            updateErrorLabel(isShow: false)
            self.callback?(self.numberRangeViewModel.selectedCategory, self.numberRangeViewModel.queryBuilder, false)
            self.dismiss(animated: true, completion: nil)
        } else {
            updateErrorLabel(isShow: true)
        }
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        self.numberRangeViewModel.resetFilter()
        self.callback?(self.numberRangeViewModel.selectedCategory, self.numberRangeViewModel.queryBuilder, false)
        self.dismiss(animated: true, completion: nil)
    }
    
    func checkForError(for minValue: String?, and maxValue: String?) {
        if numberRangeViewModel.isValidationPassed(minValue: minValue, maxValue: maxValue) {
            updateErrorLabel(isShow: false)
        } else {
            updateErrorLabel(isShow: true)
        }
    }
    
    func updateErrorLabel(isShow: Bool) {
        if isShow {
            errorLabel.text = LocalizationConstants.AdvanceSearch.invalidFormat
        } else {
            errorLabel.text = nil
        }
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

// MARK: - Text Field Delegate
extension SearchNumberRangeComponentViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        
        if textField == minRangeTextField {
            let text = textField.updatedText(for: range, replacementString: string)
            checkForError(for: text, and: maxRangeTextField.text)
        } else {
            let text = textField.updatedText(for: range, replacementString: string)
            checkForError(for: minRangeTextField.text, and: text)
        }
        return true
    }
}

// MARK: - Storyboard Instantiable
extension SearchNumberRangeComponentViewController: SearchComponentsStoryboardInstantiable { }

