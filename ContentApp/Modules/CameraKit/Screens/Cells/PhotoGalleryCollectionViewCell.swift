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

class PhotoGalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var assetImageView: UIImageView!
    @IBOutlet weak var selectedIcon: UIImageView!
    @IBOutlet weak var assetIsVideoIcon: UIImageView!
    @IBOutlet var assetImageViewConstraints: [NSLayoutConstraint]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assetImageView.layer.cornerRadius = 8.0
        assetImageView.layer.masksToBounds = true
        selectedIcon.image = UIImage(named: "ic-gallery-unselected")
        assetIsVideoIcon.isHidden = true
        contentView.layer.cornerRadius = 8.0
        contentView.layer.masksToBounds = true
    }
    
    // MARK: - Public Methods
    
    func assetImageViewTargetSize() -> CGSize {
        return CGSize(width: 80, height: 80)
    }
    
    func assest(isVideo: Bool) {
        assetIsVideoIcon.isHidden = !isVideo
    }
    
    func asset(selected: Bool) {
        let iconNamed = (selected) ? "ic-gallery-selected" : "ic-gallery-unselected"
        let margin: CGFloat = (selected) ? 12.0 : 0.0
        
        selectedIcon.image = UIImage(named: iconNamed)
        for constraint in assetImageViewConstraints {
            constraint.constant = margin
        }
        layoutIfNeeded()
    }
}
