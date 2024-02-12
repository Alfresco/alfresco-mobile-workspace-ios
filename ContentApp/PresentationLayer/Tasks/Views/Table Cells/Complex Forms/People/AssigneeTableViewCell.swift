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

class AssigneeTableViewCell: UITableViewCell, CellConfigurable {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var peopleLabel: UILabel!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userImageBaseView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    var viewModel: AssigneeTableViewCellViewModel?
    var service: MaterialDesignThemingService?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageBaseView.layer.cornerRadius = userImageBaseView.frame.size.height/2.0
        userView.layer.cornerRadius = userView.frame.size.height/2.0
        addUserButton.setTitle("", for: .normal)
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? AssigneeTableViewCellViewModel else { return }
        self.viewModel = viewModel
        peopleLabel.text = viewModel.name
        addAccessibility()
    }
    
    private func addAccessibility() {
        peopleLabel.accessibilityTraits = .staticText
        peopleLabel.accessibilityIdentifier = peopleLabel.text
        peopleLabel.accessibilityLabel = peopleLabel.text
        peopleLabel.accessibilityHint = peopleLabel.text
        peopleLabel.accessibilityValue = peopleLabel.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.service = service
        self.backgroundColor = currentTheme.surfaceColor
        peopleLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        userLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        baseView.backgroundColor = currentTheme.surfaceColor
        userView.backgroundColor = currentTheme.onSurface5Color
<<<<<<< Updated upstream
=======
        if viewModel?.userName?.count ?? 0 > 0 {
            addUserButton.setImage(UIImage(named: "ic-edit-icon"), for: .normal)
            addUserButton.tintColor = currentTheme.onSurfaceColor
        } else {
            addUserButton.setImage(UIImage(named: "ic-add"), for: .normal)
        }
>>>>>>> Stashed changes
        updateUserImage()
    }
    
    private func updateUserImage() {
        guard let currentTheme = service?.activeTheme else { return }
        
        if let userName = viewModel?.userName {
            userLabel.text = userName
            let attributes = getTextAttributes()
            userImageView.setImageForName(userName, backgroundColor: currentTheme.onSurface12Color, circular: true, textAttributes: attributes, gradient: false)
        }
    }
    
    private func getTextAttributes() -> [NSAttributedString.Key: AnyObject]? {
        guard let currentTheme = service?.activeTheme else { return nil }
        return [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.inter(style: .medium, size: 12.0),
                    NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): currentTheme.onSurface12TextColor]
    }
}
