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
import VisionKit

class ScanDocumentsViewController: SystemThemableViewController {
    weak var fileManagerDelegate: FileManagerAssetDelegate?
    var fileManagerDataSource: FileManagerDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()
        ApplicationBootstrap.shared().configureCameraKitTheme()
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.showDocumentScanner()
        })
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let theme = CameraKit.theme else { return }
        view.backgroundColor = theme.surfaceColor
    }
}

// MARK: - Document Scanner delegate
extension ScanDocumentsViewController: VNDocumentCameraViewControllerDelegate {
    func showDocumentScanner() {
        let scanningDocumentVC = VNDocumentCameraViewController()
        scanningDocumentVC.delegate = self
        self.present(scanningDocumentVC, animated: true)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images = [UIImage]()
        for page in 0 ..< scan.pageCount {
            let image = scan.imageOfPage(at: page)
            images.append(image)
        }
        controller.dismiss(animated: false) {
            self.dismiss(animated: true) {
                self.createPDF(with: images)
            }
        }
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: false) {
            self.dismiss(animated: true)
        }
    }
    
    func createPDF(with images: [UIImage]) {
        AlfrescoLog.debug("Images: \(images)")
        let pdf = images.makePDF()
        if let data = pdf?.dataRepresentation() {
            let name = UIFunction.defaultFileName(with: prefixPDFFileName)
            PDCache.shared.saveData(obj: data, fileName: name)
            if let url = PDCache.shared.getData(fileName: name) {
                fileManagerDataSource?.fetchSelectedAssets(for: [url], and: fileManagerDelegate, isScannedDocument: true)
            }
        }
    }
}

// MARK: - Storyboard Instantiable
extension ScanDocumentsViewController: CameraStoryboardInstantiable { }
