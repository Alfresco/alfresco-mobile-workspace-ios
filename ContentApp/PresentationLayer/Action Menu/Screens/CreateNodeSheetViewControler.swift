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
import AlfrescoContent

class CreateNodeSheetViewControler: SystemThemableViewController {

    @IBOutlet weak var titleCreate: UILabel!
    @IBOutlet weak var nameTextField: MDCOutlinedTextField!
    @IBOutlet weak var descriptionTextArea: MDCOutlinedTextArea!
    @IBOutlet weak var uploadButton: MDCButton!
    @IBOutlet weak var cancelButton: MDCButton!
    var createNodeViewModel: CreateNodeViewModel?
    var createTaskViewModel: CreateTaskViewModel?
    var isRenameNode = false
    let maxLengthOfTextField = 255
    let maxLengthOfTextView = 500
    var enableUploadButton = false {
        didSet {
            uploadButton.isEnabled = enableUploadButton
        }
    }
    weak var createNodeCoordinatorDelegate: CreateNodeCoordinatorDelegate?
    typealias TaskOperationCallBack = (_ task: TaskNode?, _ title: String?, _ description: String?) -> Void
    var callBack: TaskOperationCallBack?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionTextArea.maximumNumberOfVisibleRows = 2
        descriptionTextArea.textView.delegate = self
        uploadButton.isEnabled = false
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        addLocalization()
        addAccessibility()
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
        if createNodeViewModel != nil {
            uploadButtonActionForNodes()
        } else if createTaskViewModel != nil {
            uploadButtonActionForTasks()
        }
    }
    
    private func uploadButtonActionForNodes() {
        let createNodeViewType = self.createNodeViewModel?.createNodeViewType ?? .create
        if var nodeName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !nodeName.isEmpty {
            self.dismiss(animated: true) { [weak self] in
                guard let sSelf = self,
                      let descriptionNode = sSelf.descriptionTextArea.textView.text else { return }
                if createNodeViewType == .rename {
                    if let node = sSelf.createNodeViewModel?.parentListNode {
                        let fileExtension = sSelf.getTitleAndExtensionForRenameNode().extensionn
                        if !fileExtension.isEmpty {
                            nodeName = nodeName + "." + sSelf.getTitleAndExtensionForRenameNode().extensionn
                        }
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
    
    private func uploadButtonActionForTasks() {
        
        if let taskName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
           !taskName.isEmpty {
            self.dismiss(animated: true) { [weak self] in
                guard let sSelf = self,
                      let taskDescription = sSelf.descriptionTextArea.textView.text else { return }
                sSelf.callBack?(sSelf.createTaskViewModel?.task, taskName, taskDescription)
            }
        }
    }

    @IBAction func cancelButtonTapped(_ sender: MDCButton) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Private Utils

    func addLocalization() {
        if createNodeViewModel != nil {
            addLocalizationForNodes()
        } else if createTaskViewModel != nil {
            addLocalizationForTasks()
        }
    }
    
    private func addAccessibility() {
        
        titleCreate.accessibilityIdentifier = "title"
        titleCreate.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleCreate.accessibilityValue = titleCreate.text

        nameTextField.accessibilityIdentifier = "name-textField"
        nameTextField.accessibilityLabel = LocalizationConstants.TextFieldPlaceholders.name
        nameTextField.accessibilityTraits = .staticText
        nameTextField.accessibilityValue = nameTextField.text
        
        descriptionTextArea.accessibilityIdentifier = "description-textView"
        descriptionTextArea.accessibilityLabel = LocalizationConstants.TextFieldPlaceholders.description
        descriptionTextArea.accessibilityTraits = .staticText
        descriptionTextArea.accessibilityValue = descriptionTextArea.textView.text

        cancelButton.accessibilityLabel = LocalizationConstants.General.cancel
        cancelButton.accessibilityIdentifier = "cancel"
        uploadButton.accessibilityLabel = uploadButton.titleLabel?.text
        uploadButton.accessibilityIdentifier = uploadButton.titleLabel?.text
        setAccessibilityFocus()
    }
    
    private func setAccessibilityFocus() {
        if let title = titleCreate, let name = nameTextField, let description = descriptionTextArea, let cancel = cancelButton, let save = uploadButton {
            self.view.accessibilityElements = [title, name, description, cancel, save]
        }
    }
    
    private func addLocalizationForNodes() {
        let createNodeViewType = self.createNodeViewModel?.createNodeViewType ?? .create
        if createNodeViewType == .rename {
            titleCreate.text = createNodeViewModel?.createAction()
            nameTextField.text = getTitleAndExtensionForRenameNode().name
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
    
    private func addLocalizationForTasks() {
        
        let title = createTaskViewModel?.title
        let uploadButtonTitle = createTaskViewModel?.uploadButtonTitle
        let taskName = createTaskViewModel?.taskName
        let taskDescription = createTaskViewModel?.taskDescription
        
        uploadButton.setTitle(uploadButtonTitle, for: .normal)
        nameTextField.text = taskName
        descriptionTextArea.textView.text = taskDescription
        cancelButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
        descriptionTextArea.label.text = LocalizationConstants.TextFieldPlaceholders.description
        nameTextField.label.text = LocalizationConstants.TextFieldPlaceholders.name
        titleCreate.text = title
        enableUploadButton(for: nameTextField.text)
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
        
        if createTaskViewModel != nil {
            let currentString = (textField.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: string)
            return newString.count <= maxLengthOfTextField
        }
        
        nameTextField.accessibilityValue = textField.text
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
        if text.hasSpecialCharacters() == true && createNodeViewModel != nil {
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

// MARK: - UITextView Delegate

extension CreateNodeSheetViewControler: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if createTaskViewModel != nil {
            let char = text.cString(using: String.Encoding.utf8)!
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                // If backspace is pressed this will call
                return true
            }
            
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            if newText.count < maxLengthOfTextView {
                return true
            } else {
                let preFixText = newText.prefix(maxLengthOfTextView)
                descriptionTextArea.textView.text = String(preFixText)
                setTextViewAccessibilityValue()
                return false
            }
        }
        setTextViewAccessibilityValue()
        return true
    }
    
    private func setTextViewAccessibilityValue() {
        descriptionTextArea.accessibilityValue = descriptionTextArea.textView.text
    }
}
