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

class SpaceTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    var viewModel: SpaceTableCellViewModel?
    var activeTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? SpaceTableCellViewModel else { return }
        self.viewModel = viewModel
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
       
        self.activeTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
    }
}
