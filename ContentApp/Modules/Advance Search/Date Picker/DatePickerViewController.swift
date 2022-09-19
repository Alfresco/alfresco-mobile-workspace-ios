//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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

class DatePickerViewController: SystemThemableViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cancelButton: MDCButton!
    @IBOutlet weak var doneButton: MDCButton!
    @IBOutlet weak var divider: UIView!
    let datePicker = UIDatePicker()
    lazy var viewModel = DatePickerViewModel()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        applyLocalization()
        applyComponentsThemes()
        addAccessibility()
    }
    
    func addAccessibility() {
        cancelButton.accessibilityLabel = LocalizationConstants.Accessibility.closeButton
        cancelButton.accessibilityIdentifier = "cancel"
        
        doneButton.accessibilityLabel = LocalizationConstants.General.done
        doneButton.accessibilityIdentifier = "done"
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
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        divider.backgroundColor = currentTheme.onSurface12Color

        cancelButton.applyTextTheme(withScheme: buttonScheme)
        cancelButton.isUppercaseTitle = false

        doneButton.applyTextTheme(withScheme: buttonScheme)
        doneButton.isUppercaseTitle = false
    }
    
    private func applyLocalization() {
        cancelButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
        doneButton.setTitle(LocalizationConstants.General.done, for: .normal)
    }
    
    // MARK: - Button Actions
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        AlfrescoLog.debug("done button action")
    }
}


// MARK: - Storyboard Instantiable
extension DatePickerViewController: SearchComponentsStoryboardInstantiable { }


