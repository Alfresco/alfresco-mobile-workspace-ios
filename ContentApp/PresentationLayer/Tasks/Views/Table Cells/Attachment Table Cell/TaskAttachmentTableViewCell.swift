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
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var attachmentView: UIView!
    @IBOutlet weak var topParentView: NSLayoutConstraint!
    @IBOutlet weak var bottomParentView: NSLayoutConstraint!
    var viewModel: TaskAttachmentTableCellViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TaskAttachmentTableCellViewModel else { return }
        self.viewModel = viewModel
        addAccessibility()
    }
    
    private func addAccessibility() {
//        baseView.accessibilityLabel = titleHeader.text
//        baseView.accessibilityIdentifier = "placeholder-title"
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.backgroundColor = .red //currentTheme.surfaceColor
        parentView.backgroundColor = currentTheme.neutral95Color
    }
}