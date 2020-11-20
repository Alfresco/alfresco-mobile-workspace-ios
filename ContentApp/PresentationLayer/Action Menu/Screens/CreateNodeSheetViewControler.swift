//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class CreateNodeSheetViewControler: SystemThemableViewController {

    @IBOutlet weak var nameTextField: MDCOutlinedTextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var uploadButton: MDCButton!
    @IBOutlet weak var cancelButton: MDCButton!

    var createNodeViewModel: CreateNodeViewModel?
    var shouldDisplayPlaceholderInTextView: Bool = true {
        didSet {
            guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
            let textColor = (shouldDisplayPlaceholderInTextView) ?
                currentTheme.onSurfaceColor.withAlphaComponent(0.6) : currentTheme.onSurfaceColor
            let text = (shouldDisplayPlaceholderInTextView) ?
                "  " + LocalizationConstants.TextFieldPlaceholders.description : ""
            descriptionTextView.text = text
            descriptionTextView.textColor = textColor
        }
    }

    var enableUploadButton: Bool = false {
        didSet {
            uploadButton.isEnabled = enableUploadButton
        }
    }

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        uploadButton.isEnabled = false
        view.layer.cornerRadius = dialogCornerRadius
        addLocalization()
        nameTextField.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    // MARK: - IBActions

    @IBAction func uploadButtonTapped(_ sender: MDCButton) {
        if let nodeName = nameTextField.text {
            self.dismiss(animated: true) { [weak self] in
                guard let sSelf = self else { return }
                sSelf.createNodeViewModel?.requestUploadNode(with: nodeName,
                                                             description: sSelf.descriptionTextView.text)
            }
        }
    }

    @IBAction func cancelButtonTapped(_ sender: MDCButton) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Utils

    func addLocalization() {
        uploadButton.setTitle(LocalizationConstants.Buttons.upload, for: .normal)
        cancelButton.setTitle(LocalizationConstants.Buttons.cancel, for: .normal)
        descriptionTextView.text = "  " + LocalizationConstants.TextFieldPlaceholders.description
        nameTextField.label.text = LocalizationConstants.TextFieldPlaceholders.name
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard
            let loginTextFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
            let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
            let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.surfaceColor

        uploadButton.applyTextTheme(withScheme: buttonScheme)
        uploadButton.setTitleColor(currentTheme.onSurfaceColor.withAlphaComponent(0.4),
                                   for: .disabled)

        cancelButton.applyTextTheme(withScheme: buttonScheme)

        nameTextField.applyTheme(withScheme: loginTextFieldScheme)
        descriptionTextView.applyStyleBody2OnSurface(theme: currentTheme)
        descriptionTextView.textColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
        descriptionTextView.layer.cornerRadius = dialogCornerRadius
        descriptionTextView.layer.borderColor = currentTheme.onSurfaceColor.withAlphaComponent(0.38).cgColor
        descriptionTextView.layer.borderWidth = 1
    }

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width, height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }
}

// MARK: - Storyboard Instantiable

extension CreateNodeSheetViewControler: StoryboardInstantiable { }

// MARK: - UITextView Delegate

extension CreateNodeSheetViewControler: UITextViewDelegate {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if shouldDisplayPlaceholderInTextView {
            shouldDisplayPlaceholderInTextView = false
        }
        return true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            shouldDisplayPlaceholderInTextView = true
        }
    }
}

// MARK: - UITextField Delegate

extension CreateNodeSheetViewControler: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        enableUploadButton = (textField.updatedText(for: range, replacementString: string) != "")
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableUploadButton = (textField.text != "")
    }
}
