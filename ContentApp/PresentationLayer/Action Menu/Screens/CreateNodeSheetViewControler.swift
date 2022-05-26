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

    @IBOutlet weak var titleCreate: UILabel!
    @IBOutlet weak var nameTextField: MDCOutlinedTextField!
    @IBOutlet weak var descriptionTextArea: MDCOutlinedTextArea!
    @IBOutlet weak var uploadButton: MDCButton!
    @IBOutlet weak var cancelButton: MDCButton!
    var createNodeViewModel: CreateNodeViewModel?
    var enableUploadButton = false {
        didSet {
            uploadButton.isEnabled = enableUploadButton
        }
    }
    weak var createNodeCoordinatorDelegate: CreateNodeCoordinatorDelegate?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextArea.maximumNumberOfVisibleRows = 2
        uploadButton.isEnabled = false
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        addLocalization()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        let createNodeViewType = self.createNodeViewModel?.createNodeViewType ?? .create
        if var nodeName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !nodeName.isEmpty {
            self.dismiss(animated: true) { [weak self] in
                guard let sSelf = self,
                      let descriptionNode = sSelf.descriptionTextArea.textView.text else { return }
                if createNodeViewType == .rename {
                    if let node = sSelf.createNodeViewModel?.parentListNode {
                        nodeName = nodeName + "." + sSelf.getTitleAndExtensionForRenameNode().extensionn
                        sSelf.createNodeViewModel?.updateNode(with: node, name: nodeName, description: (descriptionNode.isEmpty) ? nil : descriptionNode)
                    }
                } else if createNodeViewType == .scanDocument {
                    sSelf.createNodeCoordinatorDelegate?.saveScannedDocument(with: nodeName, description: (descriptionNode.isEmpty) ? nil : descriptionNode)
                } else {
                    sSelf.createNodeViewModel?.createNode(with: nodeName,
                                                          description: (descriptionNode.isEmpty) ? nil : descriptionNode)
                }
            }
        }
    }

    @IBAction func cancelButtonTapped(_ sender: MDCButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Utils

    func addLocalization() {
        let createNodeViewType = self.createNodeViewModel?.createNodeViewType ?? .create
        if createNodeViewType == .rename {
            titleCreate.text = createNodeViewModel?.createAction()
            nameTextField.text = self.createNodeViewModel?.parentListNode.title ?? ""
            uploadButton.setTitle(LocalizationConstants.General.save, for: .normal)
            enableUploadButton(for: nameTextField.text)
        } else if createNodeViewType == .scanDocument {
            titleCreate.text = LocalizationConstants.General.create
            nameTextField.text = getTitleForScannedDocument()
            uploadButton.setTitle(LocalizationConstants.General.create, for: .normal)
            enableUploadButton(for: nameTextField.text)
        } else {
            titleCreate.text = createNodeViewModel?.createAction()
            uploadButton.setTitle(LocalizationConstants.General.create, for: .normal)
        }
        cancelButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
        descriptionTextArea.label.text = LocalizationConstants.TextFieldPlaceholders.description
        nameTextField.label.text = LocalizationConstants.TextFieldPlaceholders.name
    }
    
    private func getTitleForScannedDocument() -> String {
        let title = self.createNodeViewModel?.parentListNode.title ?? ""
        let titleArray = title.components(separatedBy: ".")
        return titleArray.first ?? ""
    }

    private func getTitleAndExtensionForRenameNode() -> (name: String, extensionn: String) {
        let title = self.createNodeViewModel?.parentListNode.title ?? ""
        let pathExtention = title.fileExtension()
        let pathPrefix = title.fileName()
        return (pathPrefix, pathExtention)
    }
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard
            let loginTextFieldScheme = coordinatorServices?.themingService?.containerScheming(for: .loginTextField),
            let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
            let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.surfaceColor

        uploadButton.applyTextTheme(withScheme: buttonScheme)
        uploadButton.isUppercaseTitle = false
        uploadButton.setTitleColor(currentTheme.onSurface30Color,
                                   for: .disabled)

        cancelButton.applyTextTheme(withScheme: buttonScheme)
        cancelButton.isUppercaseTitle = false

        titleCreate.applyStyleSubtitle1OnSurface(theme: currentTheme)
        titleCreate.textAlignment = .left

        nameTextField.applyTheme(withScheme: loginTextFieldScheme)
        nameTextField.trailingViewMode = .unlessEditing

        descriptionTextArea.applyTheme(withScheme: loginTextFieldScheme)
    }

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }
}

// MARK: - Storyboard Instantiable

extension CreateNodeSheetViewControler: StoryboardInstantiable { }

// MARK: - UITextField Delegate

extension CreateNodeSheetViewControler: UITextFieldDelegate {

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        enableUploadButton(for: textField.updatedText(for: range, replacementString: string))
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        enableUploadButton(for: "")
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        enableUploadButton(for: textField.text)
    }

    func enableUploadButton(for text: String?) {
        guard let text = text else {
            enableUploadButton = false
            disableErrorOnTextField()
            return
        }
        if text.hasSpecialCharacters() == true {
            let message = String(format: LocalizationConstants.Errors.errorNodeNameSpecialCharacters,
                                 String.specialCharacters())
            applyErrorOnTextField(with: message)
        } else if !text.isEmpty {
            disableErrorOnTextField()
        }
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            enableUploadButton = false
        }

        if createNodeViewModel?.creatingNewFolder() == true {
            let textTrimm = text.trimmingCharacters(in: .whitespacesAndNewlines)
            if textTrimm.last == "." {
                let message = String(format: LocalizationConstants.Errors.errorFolderNameEndPeriod,
                                     ".")
                applyErrorOnTextField(with: message)
            } else if textTrimm.isEmpty && !text.isEmpty {
                let message = String(format: LocalizationConstants.Errors.errorFolderNameContainOnlySpaces,
                                     ".")
                applyErrorOnTextField(with: message)
            }
        }
    }

    func applyErrorOnTextField(with message: String) {
        guard let loginTextFieldScheme =
                coordinatorServices?.themingService?.containerScheming(for: .loginTextField)
        else { return }
        enableUploadButton = false
        nameTextField.applyErrorTheme(withScheme: loginTextFieldScheme)
        nameTextField.leadingAssistiveLabel.text = message
        nameTextField.trailingView = UIImageView(image: UIImage(named: "ic-error-textfield"))
    }

    func disableErrorOnTextField() {
        guard let loginTextFieldScheme =
                coordinatorServices?.themingService?.containerScheming(for: .loginTextField)
        else { return }
        enableUploadButton = true
        nameTextField.applyTheme(withScheme: loginTextFieldScheme)
        nameTextField.leadingAssistiveLabel.text = ""
        nameTextField.trailingView = nil
    }
}
