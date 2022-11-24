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

class TaskHeaderTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var titleHeaderLabel: UILabel!
    @IBOutlet weak var titleSubHeaderLabel: UILabel!
    @IBOutlet weak var topSubHeader: NSLayoutConstraint!
    var viewModel: TaskHeaderTableCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TaskHeaderTableCellViewModel else { return }
        self.viewModel = viewModel
        
        titleHeaderLabel.text = viewModel.title
        titleSubHeaderLabel.text = viewModel.subTitle
        viewAllButton.setTitle(viewModel.buttonTitle, for: .normal)
        viewAllButton.isHidden = viewModel.isHideDetailButton
        topSubHeader.constant = viewModel.topSubHeader
        addAccessibility()
    }
    
    private func addAccessibility() {
        titleHeaderLabel.accessibilityLabel = titleHeaderLabel.text
        titleSubHeaderLabel.accessibilityLabel = titleSubHeaderLabel.text
        titleHeaderLabel.accessibilityTraits = .staticText
        titleSubHeaderLabel.accessibilityTraits = .staticText

        titleHeaderLabel.accessibilityIdentifier = "header-title"
        titleSubHeaderLabel.accessibilityIdentifier = "header-sub-title"
        viewAllButton.accessibilityIdentifier = "view-all-button"
    }
    
    @IBAction func viewAllButtonAction(_ sender: Any) {
        viewModel?.viewAllAction?()
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = currentTheme.surfaceColor
        titleHeaderLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        titleSubHeaderLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        viewAllButton.titleLabel?.font = currentTheme.buttonTextStyle.font
        viewAllButton.setTitleColor(currentTheme.primaryT1Color, for: .normal)
    }
}
