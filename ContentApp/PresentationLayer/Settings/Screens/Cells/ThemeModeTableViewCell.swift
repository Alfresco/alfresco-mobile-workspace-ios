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

class ThemeModeTableViewCell: UITableViewCell {

    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var item: ThemeModeType? {
        didSet {
            if let item = item {
                radioImageView.image = UIImage(named: "radio-button-unchecked")
                switch item {
                case .auto:
                    titleLabel.text = LocalizationConstants.Theme.auto
                case .light:
                    titleLabel.text = LocalizationConstants.Theme.light
                case .dark:
                    titleLabel.text = LocalizationConstants.Theme.dark
                }
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func selectRadioButton() {
        radioImageView.image = UIImage(named: "radio-button-checked")
    }

    func applyThemingService(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        titleLabel.applyStyleSubtitle1(theme: currentTheme)
        radioImageView.tintColor = currentTheme.surfaceOnColor.withAlphaComponent(0.6)
    }
}
