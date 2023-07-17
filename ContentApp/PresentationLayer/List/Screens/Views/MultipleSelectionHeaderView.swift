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
import MaterialComponents

class MultipleSelectionHeaderView: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var moreButton: MDCButton!
    @IBOutlet weak var moveButton: MDCButton!
    @IBOutlet weak var crossButton: MDCButton!
    @IBOutlet weak var titleHeader: UILabel!
    var didSelectMoreButtonAction: (() -> Void)?
    var didSelectMoveButtonAction: (() -> Void)?
    var didSelectResetButtonAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func applyComponentsThemes(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }

        backgroundColor = currentTheme.surfaceColor
        baseView.backgroundColor = currentTheme.surfaceColor
        divider.backgroundColor = currentTheme.dividerColor
        
        moreButton.tintColor = currentTheme.primaryT1Color
        moreButton.backgroundColor = currentTheme.surfaceColor
        
        moveButton.tintColor = currentTheme.primaryT1Color
        moveButton.backgroundColor = currentTheme.surfaceColor
        
        crossButton.tintColor = currentTheme.primaryT1Color
        crossButton.backgroundColor = currentTheme.surfaceColor
        
        titleHeader.applyStyleSubtitle1OnSurface(theme: currentTheme)
        titleHeader.textColor = currentTheme.primaryT1Color
    }
    
    func updateTitle(text: String?) {
        titleHeader.text = text
    }
    
    // MARK: - Button Actions
    @IBAction func moreButtonAction(_ sender: Any) {
        didSelectMoreButtonAction?()
    }
    
    @IBAction func moveButtonAction(_ sender: Any) {
        didSelectMoveButtonAction?()
    }
    
    @IBAction func crossButtonAction(_ sender: Any) {
        didSelectResetButtonAction?()
    }
}
