//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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

class EmptyWorkflowListCollectionViewCell: ListSelectableCell {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var imageViewEmptyWorkflows: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var emptyImageViewContraintHeight: NSLayoutConstraint!
    
    var currentTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        addAccessibility(title: LocalizationConstants.Accessibility.title, subtitle: LocalizationConstants.Workflows.workflowsUnavailableTitle)
    }
    
    private func addAccessibility(title: String, subtitle: String) {
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleLabel.accessibilityValue = title
        subTitleLabel.accessibilityLabel = LocalizationConstants.Accessibility.subTitle
        subTitleLabel.accessibilityValue = subtitle
        
        titleLabel.accessibilityIdentifier = "title"
        subTitleLabel.accessibilityIdentifier = "sub-title"
        imageViewEmptyWorkflows.accessibilityIdentifier = "empty-imageView"
    }
    
    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        backgroundColor = currentTheme.surfaceColor

        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        titleLabel.textAlignment = .center
        subTitleLabel.applyStyleSubtitle2OnSurface30(theme: currentTheme)
        subTitleLabel.textAlignment = .center
    }
    
    func setupData() {
        titleLabel.text = LocalizationConstants.Workflows.workflowsUnavailableTitle
        subTitleLabel.text = LocalizationConstants.Workflows.workflowsUnavailableMessage
    }
    
    func setupActionData() {
        imageViewEmptyWorkflows.isHidden = true
        emptyImageViewContraintHeight.constant = 0
        let title = LocalizationConstants.ActionMenu.actionUnavailableTitle
        let subtitle = LocalizationConstants.ActionMenu.actionUnavailableMessage
        titleLabel.text = title
        subTitleLabel.text = subtitle
        addAccessibility(title: title, subtitle: subtitle)
    }
}
