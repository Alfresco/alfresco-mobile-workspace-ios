//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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
import MaterialComponents

class AddAttachmentComplexTableViewCell: UITableViewCell, CellConfigurable, CellThemeApplier {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var attachmentCount: UILabel!
    @IBOutlet weak var attachmentButton: UIButton!
    var viewModel: AddAttachmentComplexTableViewCellViewModel?
    var service: MaterialDesignThemingService?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        attachmentCount.isAccessibilityElement = true
        attachmentButton.isAccessibilityElement = true
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? AddAttachmentComplexTableViewCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.name
        if !viewModel.attachments.isEmpty {
            let count = viewModel.attachments.count
            attachmentCount.text = String(format: LocalizationConstants.Tasks.multipleAttachmentsTitle, count)
        } else {
            attachmentCount.text = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
        }
        addAccessibility()
    }
    
    private func addAccessibility() {
        titleLabel.accessibilityTraits = .staticText
        titleLabel.accessibilityLabel = ""
        titleLabel.accessibilityValue = ""
        titleLabel.accessibilityIdentifier = "\(String(describing: self.titleLabel.text))"

        attachmentCount.accessibilityIdentifier = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
        attachmentCount.accessibilityLabel = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
        attachmentCount.accessibilityValue = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
        
        attachmentButton.accessibilityLabel = ""
        attachmentButton.accessibilityHint = ""
        attachmentButton.accessibilityValue = ""
        attachmentButton.accessibilityIdentifier = "add-attachment"

    }
    
    func applyCellTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
       
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        attachmentCount.applyStyleSubtitle2OnSurface60(theme: currentTheme)
    }
}
