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

class PriorityTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var priorityIcon: UIImageView!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editImageView: UIImageView!
    var viewModel: PriorityTableCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        priorityView.layer.cornerRadius = priorityView.frame.size.height / 2.0
        addTapGesture()
        baseView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        priorityLabel.isAccessibilityElement = true
        editImageView.isAccessibilityElement = true
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.editTaskAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func editTaskAction(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.didSelectEditPriority?()
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? PriorityTableCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        editImageView.isHidden = viewModel.isHideEditImage
        addAccessibility()
    }
    
    private func addAccessibility() {
        titleLabel.accessibilityIdentifier = titleLabel.text
        titleLabel.accessibilityLabel = titleLabel.text
        
        priorityLabel.accessibilityTraits = .staticText
        priorityLabel.accessibilityIdentifier = viewModel?.priority
        priorityLabel.accessibilityLabel = viewModel?.priority

        editImageView.accessibilityTraits = .button
        editImageView.accessibilityLabel = LocalizationConstants.General.edit
        editImageView.accessibilityIdentifier = "edit"
                
        if let title = titleLabel, let priority = priorityLabel, let edit = editImageView {
            self.accessibilityElements = [title, priority ]
            if !editImageView.isHidden {
                self.accessibilityElements?.append(edit)
            }
        }
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = currentTheme.surfaceColor
        priorityIcon.tintColor = currentTheme.onSurfaceColor
        titleLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        
        priorityLabel.textColor = viewModel?.priorityTextColor
        priorityView.backgroundColor = viewModel?.priorityBackgroundColor
        priorityLabel.text = viewModel?.priority
        
        editImageView.image = UIImage(named: "ic-edit-icon")
        editImageView.tintColor = currentTheme.onSurfaceColor
    }
}
