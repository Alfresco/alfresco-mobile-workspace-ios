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

class PreviewController: NSObject {
    var previewViewModel: PreviewViewModel?
    var capturedAssetsViewModel = [PreviewCellViewModel]()
    var didTrashCapturedAsset: ((Int, CapturedAsset) -> Void)?
    var didDisplayErrorOnSaveButton: ((Int, String) -> Void)?

    // MARK: - Cell Identifiers
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is PreviewCellViewModel:
            return PreviewCollectionViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Build View Models
    func buildViewModels() {
        guard let previewViewModel = self.previewViewModel else {
            return
        }
        var arrayVMs = [PreviewCellViewModel]()
        for (index, capturedAsset) in previewViewModel.capturedAssets.value.enumerated() {
            let model = PreviewCellViewModel(capturedAssets: capturedAsset)
            arrayVMs.append(model)

            model.didSelectTrash = { (capturedAsset) in
                self.didTrashCapturedAsset?(index, capturedAsset)
            }
        }
        
        self.capturedAssetsViewModel = arrayVMs
    }
    
    func enableSaveButtonAction() {
        guard let previewViewModel = self.previewViewModel else {
            return
        }
        
        previewViewModel.validateFileNames(in: nil, handler: { (index, error) in
            let errorMessage = error ?? ""
            self.didDisplayErrorOnSaveButton?(index, errorMessage)
        })
    }
}
