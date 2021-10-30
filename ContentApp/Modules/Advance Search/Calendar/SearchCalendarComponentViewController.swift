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
    var selectedTextField: MDCOutlinedTextField!
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
              let textFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
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
        
        fromTextField.applyTheme(withScheme: textFieldScheme)
        fromTextField.trailingViewMode = .unlessEditing
        fromTextField.trailingViewMode = .always
        fromTextField.trailingView = UIImageView(image: UIImage(named: "calendar-icon"))
        fromTextField.trailingView?.tintColor = currentTheme.onSurfaceColor
        
        toTextField.applyTheme(withScheme: textFieldScheme)
        toTextField.trailingViewMode = .unlessEditing
        toTextField.trailingViewMode = .always
        toTextField.trailingView = UIImageView(image: UIImage(named: "calendar-icon"))
        toTextField.trailingView?.tintColor = currentTheme.onSurfaceColor
        
        // to disable cursor
        fromTextField.tintColor = .clear
        toTextField.tintColor = .clear
    }
    
    private func applyLocalization() {
        headerTitleLabel.text = calendarViewModel.title
        applyButton.setTitle(LocalizationConstants.AdvanceSearch.apply, for: .normal)
        resetButton.setTitle(LocalizationConstants.AdvanceSearch.reset, for: .normal)
        fromTextField.label.text = LocalizationConstants.AdvanceSearch.fromKeyword
        toTextField.label.text = LocalizationConstants.AdvanceSearch.toKeyword
    }
    
    @IBAction func dismissComponentButtonAction(_ sender: Any) {
        self.callback?(self.calendarViewModel.selectedCategory)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        self.dismissComponentButtonAction(Any.self)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        self.dismissComponentButtonAction(Any.self)
    }
}

// MARK: - Textfield Delegate
extension SearchCalendarComponentViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == fromTextField {
            selectedTextField = fromTextField
        } else if textField == toTextField {
            selectedTextField = toTextField
        }
        showDatePicker()
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

// MARK: - Date Picker
extension SearchCalendarComponentViewController {
    func showDatePicker() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.backgroundColor = currentTheme.surfaceColor
        selectedTextField.inputView = datePicker
        selectedTextField.inputAccessoryView = getToolBar()
    }
    
    func getToolBar() -> UIToolbar {
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: 44.0))
        let cancelButton = UIBarButtonItem(title: LocalizationConstants.General.cancel, style: .plain, target: self, action: #selector(self.dismissToolBar))
        let doneButton = UIBarButtonItem(title: LocalizationConstants.General.done, style: .done, target: self, action: #selector(self.doneBtnClick))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton, flexibleButton, doneButton], animated: false)
        return toolBar
    }
    
    @objc func dismissToolBar() {
        self.view.endEditing(true)
    }
    
    @objc func doneBtnClick() {
        if let datePicker = selectedTextField.inputView as? UIDatePicker {
            let date = calendarViewModel.selectedDateString(for: datePicker.date)
            selectedTextField.text = date
        }
        dismissToolBar()
    }
}

// MARK: - Storyboard Instantiable
extension SearchCalendarComponentViewController: SearchComponentsStoryboardInstantiable { }

