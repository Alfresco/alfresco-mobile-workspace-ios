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

class TitleTableViewCell: UITableViewCell, CellConfigurable {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    var viewModel: TitleTableCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        subTitleLabel.isAccessibilityElement = true
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TitleTableCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
        addAccessibility()
    }
    
    private func addAccessibility() {        
        titleLabel.accessibilityIdentifier = "title"
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleLabel.accessibilityValue = titleLabel.text
        
        subTitleLabel.accessibilityIdentifier = "sub-title"
        subTitleLabel.accessibilityLabel = LocalizationConstants.Accessibility.descriptionTitle
        subTitleLabel.accessibilityValue = subTitleLabel.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = currentTheme.surfaceColor
        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        subTitleLabel.applyStyleSubtitle2OnSurface30(theme: currentTheme)
    }
}
