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

class TaskAttachmentTableViewCell: UITableViewCell, CellConfigurable {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var topAttachmentView: NSLayoutConstraint!
    @IBOutlet weak var bottomAttachmentView: NSLayoutConstraint!
    var viewModel: TaskAttachmentTableCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        attachmentView.layer.cornerRadius = 6.0
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TaskAttachmentTableCellViewModel else { return }
        self.viewModel = viewModel
        title.text = viewModel.name
        iconImageView.image = viewModel.icon
        topAttachmentView.constant = viewModel.topConstraint
        bottomAttachmentView.constant = viewModel.bottomConstraint
        addAccessibility()
    }
    
    private func addAccessibility() {
        baseView.accessibilityLabel = title.text
        baseView.accessibilityIdentifier = "task-attachment"
        baseView.accessibilityTraits = .button
    }
    
    @IBAction func didSelectButtonAction(_ sender: Any) {
        viewModel?.didSelectTaskAttachment?()
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor =  .clear // currentTheme.neutral95Color
        title.applyStyleBody1OnSurface(theme: currentTheme)
        iconImageView.tintColor = currentTheme.onSurface60Color
        
        attachmentView.layer.borderWidth = 1.0
        attachmentView.layer.borderColor = currentTheme.neutral95Color.cgColor
    }
}
