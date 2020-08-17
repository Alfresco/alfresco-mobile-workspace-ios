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
import PDFKit

class PreviewFileViewController: SystemThemableViewController {
    var previewFileViewModel: PreviewFileViewModel?
    var pdfView = PDFView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(pdfView)
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        previewFileViewModel?.requestPDFContent()
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension PreviewFileViewController: PreviewFileViewModelDelegate {
    func display(text: String) {
    }

    func display(pdf data: Data) {
        pdfView.document = PDFDocument(data: data)
    }

    func display(error: Error) {

    }
}

// MARK: - Storyboard Instantiable

extension PreviewFileViewController: StoryboardInstantiable { }
