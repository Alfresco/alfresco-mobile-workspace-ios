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

class AddAttachmentTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var viewModel: AddAttachmentTableCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? AddAttachmentTableCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        addAccessibility()
    }
    
    private func addAccessibility() {
        baseView.accessibilityLabel = titleLabel.text
        baseView.accessibilityIdentifier = "add-attachment"
        baseView.accessibilityTraits = .button
    }
    
    @IBAction func addAttachmentButtonAction(_ sender: Any) {
        viewModel?.didSelectAddAttachment?()
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor =  .clear
        titleLabel.textColor = currentTheme.primaryT1Color
        titleLabel.font = currentTheme.subtitle2TextStyle.font
    }
}
