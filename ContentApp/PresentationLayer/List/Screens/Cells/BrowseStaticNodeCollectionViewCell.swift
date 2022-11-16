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

class BrowseStaticNodeCollectionViewCell: ListSelectableCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var node: BrowseNode? {
        didSet {
            if let node = node {
                iconImageView.image = UIImage(named: node.icon)
                titleLabel.text = node.title
                titleLabel.accessibilityIdentifier = node.accessibilityId
                switch node.type {
                case .myLibraries:
                    self.accessibilityIdentifier = "myLibrariesCell"
                case .personalFiles:
                    self.accessibilityIdentifier = "personalFilesCell"
                case .shared:
                    self.accessibilityIdentifier = "sharedCell"
                case .trash:
                    self.accessibilityIdentifier = "trashCell"
                }
            }
        }
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        backgroundColor = currentTheme.surfaceColor
        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        iconImageView.tintColor = currentTheme.onSurface60Color
    }
}
