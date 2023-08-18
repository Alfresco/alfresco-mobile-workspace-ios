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
import AVKit
import AVFoundation
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextAreas
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class PreviewViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var fileNameTextField: MDCOutlinedTextField!
    @IBOutlet weak var descriptionField: MDCOutlinedTextArea!
    @IBOutlet weak var saveButton: MDCButton!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!
    weak var cameraDelegate: CameraKitCaptureDelegate?
    lazy var controller = PreviewController()
    var previewViewModel: PreviewViewModel? {
        return controller.previewViewModel
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        registerCells()
        applyLocalization()
        applyComponentsThemes()
        setupBindings()
        controller.enableSaveButtonAction()
        
        descriptionField.textView.delegate = self
        descriptionField.baseTextAreaDelegate = self
        descriptionField.minimumNumberOfVisibleRows = 1
        descriptionField.maximumNumberOfVisibleRows = 7
        descriptionField.textView.accessibilityIdentifier = "descriptionTextField"
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func registerCells() {
        collectionView.register(UINib(nibName: CellConstants.CollectionCells.preview, bundle: nil), forCellWithReuseIdentifier: CellConstants.CollectionCells.preview)
        collectionView.dataSource = self
        collectionView.delegate = self
        setCollectionViewFlowLayout()
    }
    
    // MARK: - Setup Bindings
    private func setupBindings() {
        
        /* observe captured assets */
        self.previewViewModel?.capturedAssets.addObserver { capturedAssets in
            self.controller.buildViewModels()
            self.collectionView.reloadData()
        }
        
        /* observe visible cell index */
        self.previewViewModel?.visibleCellIndex.addObserver({ (index) in
            guard let capturdAsset = self.previewViewModel?.capturedAssets.value[index] else { return }
            self.updateTextViewLocalization()
            self.fileNameTextField.text = self.previewViewModel?.assetFilename(for: capturdAsset)
            self.descriptionField.textView.text = self.previewViewModel?.assetDescription(for: capturdAsset)
            self.controller.enableSaveButtonAction()
        })
        
        /* observer save button error message */
        self.controller.didDisplayErrorOnSaveButton = {(index, message) in
            self.enableSaveButton(for: index, and: message)
        }
        
        /* observer delete asset */
        self.controller.didTrashCapturedAsset = { (index, capturedAsset) in
            self.trashButtonTapped(at: index, and: capturedAsset)
        }
    }
    
    private func updateTextViewLocalization() {
        guard let localization = CameraKit.localization, let theme = CameraKit.theme else { return }
        descriptionField.label.text = localization.descriptionTextField
        descriptionField.applyTheme(withScheme: theme.textFieldScheme)
    }

    // MARK: - IBActions
    @IBAction func saveButtonTapped(_ sender: MDCButton) {
        self.view.endEditing(true)
        self.previewViewModel?.validateFileNames(in: self, handler: { (index, error) in
            self.scrollCollectionView(to: index)
            if index < 0 {
                self.uploadCapturedAssets()
            }
        })
    }
    
    private func uploadCapturedAssets() {
        if let capturedAssets = self.previewViewModel?.capturedAssets.value {
            cameraDelegate?.didEndReview(for: capturedAssets)
            navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func scrollCollectionView(to index: Int) {
        if index >= 0 {
            let indexPath = IndexPath(row: index, section: 0)
            self.previewViewModel?.visibleCellIndex.value = index
            self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }

    private func trashButtonTapped(at index: Int, and capturedAsset: CapturedAsset) {
        guard let capturedAsset = self.previewViewModel?.capturedAssets.value[index] else { return }
        capturedAsset.deleteAsset()
        self.previewViewModel?.capturedAssets.value.remove(at: index)
        self.updateVisibleCellIndex()
        self.previewViewModel?.callback?(index)
        if self.previewViewModel?.capturedAssets.value.isEmpty == true {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateVisibleCellIndex() {
        guard let capturedAssets = self.previewViewModel?.capturedAssets.value, let visibleCellIndex = self.previewViewModel?.visibleCellIndex.value  else { return }
        if !capturedAssets.isEmpty {
            if visibleCellIndex >= capturedAssets.count {
                self.previewViewModel?.visibleCellIndex.value = capturedAssets.count - 1
            } else {
                self.previewViewModel?.visibleCellIndex.value = visibleCellIndex
            }
        }
    }

    private func enableSaveButton(for index: Int, and message: String) {
        if index >= 0 && !message.isEmpty {
            self.saveButton.isEnabled = false
        } else {
            self.saveButton.isEnabled = true
        }
        self.displayErrorOnTextField(for: index, and: message)
    }
    
    private func displayErrorOnTextField(for index: Int, and message: String) {
        if index == self.previewViewModel?.visibleCellIndex.value {
            applyErrorOnTextField(with: message)
        } else {
            disableErrorOnTextField()
        }
    }
    
    private func applyErrorOnTextField(with message: String) {
        guard let theme = CameraKit.theme else { return }
        fileNameTextField.applyErrorTheme(withScheme: theme.textFieldScheme)
        fileNameTextField.leadingAssistiveLabel.text = message
        fileNameTextField.trailingView = UIImageView(image: UIImage(named: "ic-error-textfield"))
    }

    private func disableErrorOnTextField() {
        guard let theme = CameraKit.theme else { return }
        fileNameTextField.applyTheme(withScheme: theme.textFieldScheme)
        fileNameTextField.leadingAssistiveLabel.text = ""
        fileNameTextField.trailingView = nil
    }
    
    // MARK: - Private Methods
    private func applyComponentsThemes() {
        guard let theme = CameraKit.theme else { return }

        collectionView.backgroundColor = .clear
        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.backgroundColor = theme.surfaceColor
                
        saveButton.applyContainedTheme(withScheme: theme.buttonScheme)
        saveButton.setBackgroundColor(theme.onSurface5Color, for: .disabled)
        saveButton.isUppercaseTitle = false
        saveButton.setShadowColor(.clear, for: .normal)
        
        fileNameTextField.applyTheme(withScheme: theme.textFieldScheme)
        fileNameTextField.trailingViewMode = .unlessEditing
        descriptionField.applyTheme(withScheme: theme.textFieldScheme)
    }
    
    private func applyLocalization() {
        guard let localization = CameraKit.localization else { return }
        
        title = localization.previewScreenTitle
        fileNameTextField.label.text = localization.fileNameTextField
        descriptionField.label.text = localization.descriptionTextField
        saveButton.setTitle(localization.saveButton, for: .normal)
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        self.navigationController?.navigationBar.addGestureRecognizer(tap)
    }
}

// MARK: - Keyboard Notificafion

extension PreviewViewController {
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let object = saveButton,
              let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let frameObjectInView = scrollView.convert(object.frame, to: view)
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let objectPositionY = view.frame.size.height
            - frameObjectInView.origin.y
            - frameObjectInView.size.height
            - saveButtonBottomConstraint.constant

        if objectPositionY < keyboardHeight {
            scrollView.frame.origin.y -= (keyboardHeight - objectPositionY)
            scrollViewTopConstraint.constant = scrollView.frame.origin.y
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if scrollView.frame.origin.y != 0 {
            scrollView.frame.origin.y = 0
        }
    }
}

// MARK: - UITextField Delegate

extension PreviewViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollViewTopConstraint.constant = scrollView.frame.origin.y
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        scrollViewTopConstraint.constant = scrollView.frame.origin.y
        var updatedText = ""
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            updatedText = text.replacingCharacters(in: textRange, with: string)
            let index = self.previewViewModel?.visibleCellIndex.value ?? 0
            self.controller.previewViewModel?.capturedAssets.value[index].fileName = updatedText
        }
        
        self.controller.enableSaveButtonAction()
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        let index = self.previewViewModel?.visibleCellIndex.value ?? 0
        self.controller.previewViewModel?.capturedAssets.value[index].fileName = ""
        self.controller.enableSaveButtonAction()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionField.textView.becomeFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollViewTopConstraint.constant = 0
        self.controller.enableSaveButtonAction()
    }
}

// MARK: - UITextView Delegate

extension PreviewViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        scrollViewTopConstraint.constant = scrollView.frame.origin.y
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        scrollViewTopConstraint.constant = 0
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let index = self.previewViewModel?.visibleCellIndex.value ?? 0
        self.controller.previewViewModel?.capturedAssets.value[index].description = textView.text
    }
}

// MARK: - MDCBaseTextArea Delegate

extension PreviewViewController: MDCBaseTextAreaDelegate {
    func baseTextArea(_ baseTextArea: MDCBaseTextArea, shouldChange newSize: CGSize) {
        if descriptionField.textView.isFirstResponder {
            guard let lineHeight = baseTextArea.textView.font?.lineHeight else { return }
            if descriptionField.frame.height < newSize.height {
                scrollView.frame.origin.y -= lineHeight
                scrollViewTopConstraint.constant = scrollView.frame.origin.y
            } else {
                scrollView.frame.origin.y += lineHeight
                scrollViewTopConstraint.constant = scrollView.frame.origin.y
            }
        }
    }
}

// MARK: - Collection View Delegate and Datasource

extension PreviewViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func setCollectionViewFlowLayout() {
        let flowLayout = CollectionFlowLayout()
        self.collectionView.collectionViewLayout = flowLayout
        collectionView.contentInsetAdjustmentBehavior = .always
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.controller.capturedAssetsViewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let rowViewModel = self.controller.capturedAssetsViewModel[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellConstants.CollectionCells.preview, for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowViewModel)
        }
        cell.layoutIfNeeded()
        cell.contentView.isUserInteractionEnabled = true
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.endEditing(true)
        let index = indexPath.row
        self.scrollCollectionView(to: index)
        
        if let node = self.listNodeForPreview(), let navigationViewController = self.navigationController {
            let coordinator = FilePreviewScreenCoordinator(with: navigationViewController,
                                                           listNode: node,
                                                           excludedActions: [.moveTrash,
                                                                             .addFavorite,
                                                                             .removeFavorite,
                                                                             .download,
                                                                             .restore,
                                                                             .permanentlyDelete,
                                                                             .markOffline,
                                                                             .removeOffline],
                                                           shouldPreviewLatestContent: false,
                                                           isLocalFilePreview: true)
            coordinator.start()
        }
    }
    
    func listNodeForPreview() -> ListNode? {
        let index = self.previewViewModel?.visibleCellIndex.value ?? 0
        guard let capturedAsset = self.previewViewModel?.capturedAssets.value[index] else { return nil }
        return ListNode(guid: "0",
                        mimeType: capturedAsset.type.mimetype,
                        title: capturedAsset.fileName,
                        path: "",
                        nodeType: .file,
                        syncStatus: .pending,
                        markedOfflineStatus: .upload,
                        allowableOperations: [],
                        uploadLocalPath: capturedAsset.filePath())
    }
}

// MARK: - Scroll View Delegate
extension PreviewViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.collectionView {
            var currentCellOffset = self.collectionView.contentOffset
            currentCellOffset.x += self.collectionView.frame.width / 2
            if let indexPath = self.collectionView.indexPathForItem(at: currentCellOffset) {
                self.previewViewModel?.visibleCellIndex.value = indexPath.row
                self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
}

// MARK: - Storyboard Instantiable
extension PreviewViewController: CameraStoryboardInstantiable { }
