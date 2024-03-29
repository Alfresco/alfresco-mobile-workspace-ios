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

class PreviewTextFileViewController: SystemThemableViewController {
    @IBOutlet weak var textView: UITextView!
    var previewFileViewModel: PreviewFileViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        previewFileViewModel?.requestTextContent()
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension PreviewTextFileViewController: PreviewFileViewModelDelegate {
    func display(text: String) {
        textView.text = text
    }

    func display(pdf data: Data) {
    }

    func display(error: Error) {

    }
}

// MARK: - Storyboard Instantiable

extension PreviewTextFileViewController: StoryboardInstantiable { }
