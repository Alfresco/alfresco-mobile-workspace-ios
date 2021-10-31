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
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class SearchCalendarComponentViewController: SystemThemableViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var dividerCalendarView: UIView!
    @IBOutlet weak var applyButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    @IBOutlet weak var fromTextField: MDCOutlinedTextField!
    @IBOutlet weak var toTextField: MDCOutlinedTextField!
    let datePicker = UIDatePicker()
    lazy var calendarViewModel = SearchCalendarComponentViewModel()
    var callback: SearchComponentCallBack?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        baseView.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        hideKeyboardWhenTappedAround()
        applyLocalization()
        applyComponentsThemes()
        datePicker.addTarget(self, action: #selector(self.handleDatePicker), for: .valueChanged)
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
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    // MARK: - Apply Themes and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
              let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        headerTitleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        dismissButton.tintColor = currentTheme.onSurfaceColor
        divider.backgroundColor = currentTheme.onSurface12Color
        dividerCalendarView.backgroundColor = currentTheme.onSurface12Color

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
        
        // text field scheme
        applyTextFieldTheme()
    }
    
    func applyTextFieldTheme() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let textFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField) else { return }
        fromTextField.applyTheme(withScheme: textFieldScheme)
        fromTextField.trailingViewMode = .unlessEditing
        fromTextField.trailingViewMode = .always
        fromTextField.trailingView = UIImageView(image: UIImage(named: "calendar-icon"))
        fromTextField.trailingView?.tintColor = currentTheme.onSurfaceColor
        fromTextField.leadingAssistiveLabel.text = nil

        toTextField.applyTheme(withScheme: textFieldScheme)
        toTextField.trailingViewMode = .unlessEditing
        toTextField.trailingViewMode = .always
        toTextField.trailingView = UIImageView(image: UIImage(named: "calendar-icon"))
        toTextField.trailingView?.tintColor = currentTheme.onSurfaceColor
        toTextField.leadingAssistiveLabel.text = nil

        // to disable cursor
        fromTextField.tintColor = .clear
        toTextField.tintColor = .clear
    }
    
    private func applyLocalization() {
        let fromDate = calendarViewModel.getPrefilledValues().fromDate
        let toDate = calendarViewModel.getPrefilledValues().toDate
        headerTitleLabel.text = calendarViewModel.title
        applyButton.setTitle(LocalizationConstants.AdvanceSearch.apply, for: .normal)
        resetButton.setTitle(LocalizationConstants.AdvanceSearch.reset, for: .normal)
        fromTextField.label.text = LocalizationConstants.AdvanceSearch.fromKeyword
        toTextField.label.text = LocalizationConstants.AdvanceSearch.toKeyword
        fromTextField.text = fromDate
        toTextField.text = toDate

    }
    
    @IBAction func dismissComponentButtonAction(_ sender: Any) {
        self.callback?(self.calendarViewModel.selectedCategory)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        if let fromDate = calendarViewModel.selectedFromDate, let toDate = calendarViewModel.selectedToDate {
            if fromDate > toDate {
                swap(parameterOne: &calendarViewModel.selectedFromDate, parameterTwo: &calendarViewModel.selectedToDate)
            }
            calendarViewModel.applyFilter(fromValue: fromTextField.text, toValue: toTextField.text)
            self.dismissComponentButtonAction(Any.self)
        } else {
            if calendarViewModel.selectedFromDate == nil {
                applyError(on: fromTextField, with: LocalizationConstants.AdvanceSearch.errorRequiredValue)
            } else if calendarViewModel.selectedToDate == nil {
                applyError(on: toTextField, with: LocalizationConstants.AdvanceSearch.errorRequiredValue)
            }
        }
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        calendarViewModel.resetFilter()
        self.dismissComponentButtonAction(Any.self)
    }
    
    private func applyError(on textField: MDCOutlinedTextField, with message: String) {
        guard let textFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField) else { return }
        textField.applyErrorTheme(withScheme: textFieldScheme)
        textField.leadingAssistiveLabel.text = message
        textField.trailingView = UIImageView(image: UIImage(named: "ic-error-textfield"))
    }
    
    func swap<T>(parameterOne: inout T, parameterTwo: inout T) {
        (parameterOne, parameterTwo) = (parameterTwo, parameterOne)
    }
}

// MARK: - Textfield Delegate
extension SearchCalendarComponentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == fromTextField {
            calendarViewModel.selectedTextField = fromTextField
        } else if textField == toTextField {
            calendarViewModel.selectedTextField = toTextField
        }
        applyTextFieldTheme()
        showDatePicker()
    }
}

// MARK: - Date Picker
extension SearchCalendarComponentViewController {
    func showDatePicker() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = currentTheme.surfaceColor
        datePicker.maximumDate = Date()
        calendarViewModel.selectedTextField.inputView = datePicker
        if calendarViewModel.selectedTextField == fromTextField, let date = calendarViewModel.selectedFromDate {
            datePicker.date = date
        } else if calendarViewModel.selectedTextField == toTextField, let date = calendarViewModel.selectedToDate {
            datePicker.date = date
        }
    }
    
    @objc func handleDatePicker() {
        if let datePicker = calendarViewModel.selectedTextField.inputView as? UIDatePicker {
            if calendarViewModel.selectedTextField == fromTextField {
                calendarViewModel.selectedFromDate = datePicker.date
            } else if calendarViewModel.selectedTextField == toTextField {
                calendarViewModel.selectedToDate = datePicker.date
            }
            let date = calendarViewModel.selectedDateString(for: datePicker.date)
            calendarViewModel.selectedTextField.text = date
        }
        applyTextFieldTheme()
        self.view.endEditing(true)
    }
}

// MARK: - Storyboard Instantiable
extension SearchCalendarComponentViewController: SearchComponentsStoryboardInstantiable { }

