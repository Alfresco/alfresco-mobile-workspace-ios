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

class AccountItemTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var item: AccountItem? {
        didSet {
            if let item = item {
                iconImageView.image = UIImage(named: item.icon)
                titleLabel.text = item.title
                subtitleLabel.text = item.subtitle
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func applyThemingService(_ themingService: MaterialDesignThemingService?) {
        titleLabel.font = themingService?.activeTheme?.accountTitleLabelFont
        titleLabel.textColor = themingService?.activeTheme?.accountTitleLabelColor
        subtitleLabel.font = themingService?.activeTheme?.accountSubtitleLabelFont
        subtitleLabel.textColor = themingService?.activeTheme?.accountSubtitleLabelColor
        iconImageView.tintColor = themingService?.activeTheme?.accountIconColor
    }
}
