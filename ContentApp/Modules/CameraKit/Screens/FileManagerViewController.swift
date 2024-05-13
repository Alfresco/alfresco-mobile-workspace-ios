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
import UniformTypeIdentifiers

class FileManagerViewController: UIViewController {

    weak var fileManagerDelegate: FileManagerAssetDelegate?
    var fileManagerDataSource: FileManagerDataSource?
    var attachmentType: AttachmentType = .content
    var multiSelection = true

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationBootstrap.shared().configureCameraKitTheme()
        applyComponentsThemes()
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.showDocumentPicker()
        })
    }
    
    // MARK: - Private Methods
    private func applyComponentsThemes() {
        guard let theme = CameraKit.theme else { return }
        view.backgroundColor = theme.surfaceColor
    }
}

// MARK: - Document Picker
extension FileManagerViewController: UIDocumentPickerDelegate {
    func showDocumentPicker() {
        let supportedTypes: [UTType] = [UTType.image, UTType.package, UTType.text, UTType.appleProtectedMPEG4Video, UTType.appleArchive, UTType.audio, UTType.content]
        let pickerViewController = UIDocumentPickerViewController(forOpeningContentTypes: supportedTypes, asCopy: true)
        pickerViewController.allowsMultipleSelection = multiSelection
        pickerViewController.delegate = self
        pickerViewController.modalPresentationStyle = .fullScreen
        self.present(pickerViewController, animated: false)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var isFileSizeExcceds = false
        
        if attachmentType == .task || attachmentType == .workflow {
            let fileLimit = attachmentType == .task ? KeyConstants.FileSize.taskFileSize : KeyConstants.FileSize.workflowFileSize
            for url in urls where url.fileSizeInMB() > fileLimit {
                isFileSizeExcceds = true
                break
            }
            if isFileSizeExcceds { // show error about maximum file size
                self.dismiss(animated: true) {
                    self.showErrorMaximumFileSizeExcceds(fileLimit: fileLimit)
                }
            }
        }
        
        if !isFileSizeExcceds { // show error about maximum file size
            fileManagerDataSource?.fetchSelectedAssets(for: urls, and: fileManagerDelegate)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func showErrorMaximumFileSizeExcceds(fileLimit: Double) {
        let errorMessage = String(format: LocalizationConstants.EditTask.errorFileSizeExceeds, fileLimit)
        Snackbar.display(with: errorMessage,
                         type: .error,
                         presentationHostViewOverride: self.navigationController?.viewControllers.last?.view,
                         finish: nil)
    }
    
}

// MARK: - Storyboard Instantiable
extension FileManagerViewController: CameraStoryboardInstantiable { }
