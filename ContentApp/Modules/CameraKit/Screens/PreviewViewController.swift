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
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var capturedAssetImageView: UIImageView!
    
    @IBOutlet weak var descriptionField: MDCOutlinedTextArea!
    @IBOutlet weak var fileNameTextField: MDCOutlinedTextField!
    @IBOutlet weak var saveButton: MDCButton!
    
    @IBOutlet weak var capturedAssetHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var capturedAssetWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var saveButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollViewTopConstraint: NSLayoutConstraint!

    var previewViewModel: PreviewViewModel?
    weak var cameraDelegate: CameraKitCaptureDelegate?
    
    var enableSaveButton = false {
        didSet {
            saveButton.isEnabled = enableSaveButton
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyLocalization()
        applyComponentsThemes()
        
        fileNameTextField.text = previewViewModel?.assetFilename()
        
        descriptionField.textView.delegate = self
        descriptionField.baseTextAreaDelegate = self
        descriptionField.minimumNumberOfVisibleRows = 1
        descriptionField.maximumNumberOfVisibleRows = 7
        descriptionField.textView.accessibilityIdentifier = "descriptionTextField"
        
        if let image = previewViewModel?.assetThumbnailImage() {
            capturedAssetImageView.image = image
            if image.imageOrientation == .down ||
                image.imageOrientation == .up {
                swapCapturedAssetRatioContraints()
            }
        }
        capturedAssetImageView.layer.cornerRadius = 8.0
        
        trashButton.layer.cornerRadius = trashButton.bounds.height / 2.0
        playButton.layer.cornerRadius = playButton.bounds.height / 2.0
        
        playButton.isHidden = !(previewViewModel?.isAssetVideo() ?? false)
        
        enableSaveButton = !(fileNameTextField.text?.isEmpty ?? false)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonTapped(_ sender: MDCButton) {
        if let filename = fileNameTextField.text,
           let capturedAsset = previewViewModel?.asset() {
            previewViewModel?.updateMetadata(filename: filename,
                                             description: descriptionField.textView.text)
            cameraDelegate?.didEndReview(for: [capturedAsset])
        }
        navigationController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func trashButtonTapped(_ sender: UIButton) {
        previewViewModel?.asset().deleteAsset()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: SegueIdentifiers.showFullScreenVideo.rawValue,
                     sender: nil)
    }
    
    @IBAction func fullScreenTapGesture(_ sender: UITapGestureRecognizer) {
        if previewViewModel?.isAssetVideo() == true {
            performSegue(withIdentifier: SegueIdentifiers.showFullScreenVideo.rawValue,
                         sender: nil)
        } else {
            performSegue(withIdentifier: SegueIdentifiers.showFullScreenPhoto.rawValue,
                         sender: nil)
        }
    }

    @IBAction func contentViewTapGesture(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Private Methods
    
    private func applyComponentsThemes() {
        guard let theme = CameraKit.theme else { return }

        scrollView.backgroundColor = .clear
        contentView.backgroundColor = .clear
        view.backgroundColor = theme.surfaceColor
        
        trashButton.tintColor = theme.onSurface60Color
        trashButton.backgroundColor = theme.surface60Color
        
        playButton.tintColor = theme.onSurface60Color
        playButton.backgroundColor = theme.surface60Color
        
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
    }
    
    private func swapCapturedAssetRatioContraints() {
        swap(&capturedAssetWidthConstraint.constant, &capturedAssetHeightContraint.constant)
        capturedAssetImageView.layoutIfNeeded()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showFullScreenPhoto.rawValue,
           let fspvc = segue.destination as? FullScreenPhotoViewController {
            fspvc.imageCapturedAsset = previewViewModel?.assetThumbnailImage()
        } else if segue.identifier == SegueIdentifiers.showFullScreenVideo.rawValue,
                  let fsvvc = segue.destination as? FullScreenVideoViewController {
            fsvvc.videoURL = previewViewModel?.videoUrl()
        }
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
        }
        enableSaveButton(for: updatedText)
        return true
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        enableSaveButton(for: "")
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        descriptionField.textView.becomeFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        scrollViewTopConstraint.constant = 0
        enableSaveButton(for: textField.text)
    }

    func enableSaveButton(for text: String?) {
        guard let text = text, let localization = CameraKit.localization else {
            enableSaveButton = false
            disableErrorOnTextField()
            return
        }
        if hasSpecialCharacters(text) == true {
            let message = String(format: localization.errorNodeNameSpecialCharacters,
                                 specialCharacters())
            applyErrorOnTextField(with: message)
        } else if text.isEmpty {
            let message = String(format: localization.errorEmptyFileName)
            applyErrorOnTextField(with: message)
        } else if !text.isEmpty {
            disableErrorOnTextField()
        }
        
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            enableSaveButton = false
        }
    }

    func applyErrorOnTextField(with message: String) {
        guard let theme = CameraKit.theme else { return }
        enableSaveButton = false
        fileNameTextField.applyErrorTheme(withScheme: theme.textFieldScheme)
        fileNameTextField.leadingAssistiveLabel.text = message
        fileNameTextField.trailingView = UIImageView(image: UIImage(named: "ic-error-textfield"))
    }

    func disableErrorOnTextField() {
        guard let theme = CameraKit.theme else { return }
        enableSaveButton = true
        fileNameTextField.applyTheme(withScheme: theme.textFieldScheme)
        fileNameTextField.leadingAssistiveLabel.text = ""
        fileNameTextField.trailingView = nil
    }
    
    func hasSpecialCharacters(_ string: String) -> Bool {
        let characterset = CharacterSet(charactersIn: "*\"<>\\/?:|")
        if string.rangeOfCharacter(from: characterset) != nil {
            return true
        }
        return false
    }

    func specialCharacters() -> String {
        return "* \" < > \\ / ? : |"
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

// MARK: - Storyboard Instantiable

extension PreviewViewController: CameraStoryboardInstantiable { }
