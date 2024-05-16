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

class OutcomesTableViewCell: UITableViewCell, CellConfigurable, CellThemeApplier {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var outcomesBtn: MDCButton!
    var viewModel: OutcomesTableViewCellViewModel?
    var service: MaterialDesignThemingService?
    var name = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        baseView.isAccessibilityElement = false
        outcomesBtn.isAccessibilityElement = true
        addAccessibility()
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? OutcomesTableViewCellViewModel else { return }
        self.viewModel = viewModel
        name = viewModel.title ?? "''"
        outcomesBtn.setTitle(name, for: .normal)
    }
    
    private func addAccessibility() {
        outcomesBtn.accessibilityLabel = self.name
        outcomesBtn.accessibilityHint = self.name
        outcomesBtn.accessibilityValue = self.name
        outcomesBtn.accessibilityIdentifier = ""
    }
    
    func applyCellTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme, let dialogButtonScheme = service?.containerScheming(for: .dialogButton) else { return }
       
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        
        outcomesBtn.applyContainedTheme(withScheme: dialogButtonScheme)
        outcomesBtn.isUppercaseTitle = false
        outcomesBtn.layer.cornerRadius = UIConstants.cornerRadiusDialog
        outcomesBtn.setShadowColor(.clear, for: .normal)
        outcomesBtn.setTitleColor(.white, for: .normal)
    }
}
