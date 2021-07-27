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

class PreviewCollectionViewCell: UICollectionViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var trashButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var capturedAssetImageView: UIImageView!
    @IBOutlet weak var baseViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var baseViewWidthConstraint: NSLayoutConstraint!
    var viewModel: PreviewCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
        applyComponentsThemes()
        baseView.layer.cornerRadius = 8.0
        capturedAssetImageView.layer.cornerRadius = baseView.layer.cornerRadius
        trashButton.layer.cornerRadius = trashButton.bounds.height / 2.0
        playButton.layer.cornerRadius = playButton.bounds.height / 2.0
        baseView.layer.masksToBounds = true
        capturedAssetImageView.layer.masksToBounds = true
        capturedAssetImageView.isUserInteractionEnabled = true
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? PreviewCellViewModel else {
            return
        }
        self.viewModel = viewModel
        if let image = viewModel.assetThumbnailImage() {
            capturedAssetImageView.image = image
        }
        self.playButton.isHidden = viewModel.isPlayButtonHidden()
    }

    @IBAction func trashButtonTapped(_ sender: UIButton) {
        self.viewModel?.selectOptionTrash()
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        self.viewModel?.selectOptionPlay()
    }
    
    private func applyComponentsThemes() {
        guard let theme = CameraKit.theme else { return }

        trashButton.tintColor = theme.onSurface60Color
        trashButton.backgroundColor = theme.surface60Color
        
        playButton.tintColor = theme.onSurface60Color
        playButton.backgroundColor = theme.surface60Color
    }
}
