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

protocol ListElementCollectionViewCellDelegate: class {
    func moreButtonTapped(for element: ListNode?)
}

class ListElementCollectionViewCell: ListSelectableCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    weak var delegate: ListElementCollectionViewCellDelegate?
    var element: ListNode? {
        didSet {
            if let element = element {
                title.text = element.title
                subtitle.text = element.path
                iconImageView.image = FileIcon.icon(for: element.mimeType)
                moreButton.isHidden = true
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        backgroundColor = currentTheme.surfaceColor
        title.applyStyleSubtitle1OnSurface(theme: currentTheme)
        title.lineBreakMode = .byTruncatingTail
        subtitle.applyStyleCaptionOnSurface60(theme: currentTheme)
        subtitle.lineBreakMode = .byTruncatingHead
        iconImageView.tintColor = currentTheme.onSurfaceColor.withAlphaComponent(0.6)
    }

    @IBAction func moreButtonTapped(_ sender: UIButton) {
        delegate?.moreButtonTapped(for: element)
    }
}
