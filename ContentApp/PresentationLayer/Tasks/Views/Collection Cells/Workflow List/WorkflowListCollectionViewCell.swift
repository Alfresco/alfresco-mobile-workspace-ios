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

class WorkflowListCollectionViewCell: ListSelectableCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var currentTheme: PresentationTheme?
    lazy var viewModel = WorkflowListCollectionViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        addAccessibility()
    }
    private func addAccessibility() {
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        subtitleLabel.accessibilityLabel = LocalizationConstants.Accessibility.assignee
        
        titleLabel.accessibilityIdentifier = "title"
        subtitleLabel.accessibilityIdentifier = "sub-title"
    }
    
    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        backgroundColor = currentTheme.surfaceColor
        titleLabel.applyStyleBody1OnSurface(theme: currentTheme)
        titleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        subtitleLabel.lineBreakMode = .byTruncatingHead
    }
    
    func setupData(for workflowAppDefinition: WFlowAppDefinitions?) {
        guard let workflowAppDefinition = workflowAppDefinition else { return }
        viewModel.workflowAppDefinition = workflowAppDefinition
        
        titleLabel.text = viewModel.name
        subtitleLabel.text = viewModel.definitionDescription
        
        titleLabel.accessibilityValue = titleLabel.text
        subtitleLabel.accessibilityValue = subtitleLabel.text
    }
}
