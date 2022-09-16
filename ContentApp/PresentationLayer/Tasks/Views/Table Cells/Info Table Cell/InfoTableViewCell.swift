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

class InfoTableViewCell: UITableViewCell, CellConfigurable {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var infoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var editImageView: UIImageView!
    var viewModel: InfoTableCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        valueLabel.isUserInteractionEnabled = true
        valueLabel.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.editTaskAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let isEditMode = viewModel?.isEditMode ?? false
        if isEditMode {
            viewModel?.didSelectValue?()
        }
    }
    
    @objc func editTaskAction(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.didSelectEditInfo?()
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? InfoTableCellViewModel else { return }
        self.viewModel = viewModel
        infoImageView.image = viewModel.image
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
        divider.isHidden = viewModel.isHideDivider
        editImageView.isHidden = viewModel.isHideEditImage
        addAccessibility()
    }
    
    private func addAccessibility() {
        baseView.accessibilityIdentifier = titleLabel.text
        baseView.accessibilityLabel = titleLabel.text
        baseView.accessibilityValue = valueLabel.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = currentTheme.surfaceColor
        infoImageView.tintColor = currentTheme.onSurfaceColor
        titleLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        valueLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        divider.backgroundColor = currentTheme.onSurface12Color
        
        editImageView.image = UIImage(named: "ic-edit-icon")
        editImageView.tintColor = currentTheme.onSurfaceColor
    }
}
