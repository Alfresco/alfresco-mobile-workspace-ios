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

class TaskAssigneeTableViewCell: UITableViewCell, CellConfigurable {
   
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var userImageBaseView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    var viewModel: TaskAssigneeTableCellViewModel?
    var currentTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageBaseView.layer.cornerRadius = userImageBaseView.frame.size.height/2.0
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TaskAssigneeTableCellViewModel else { return }
        self.viewModel = viewModel
        
        updateUserImage()
        userNameLabel.text = viewModel.displayName()
        addAccessibility()
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        baseView.addGestureRecognizer(tap)
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.didSelectUserAction?()
    }
    
    private func updateUserImage() {
        if let userName = viewModel?.displayName(), let currentTheme = currentTheme {
            let attributes = getTextAttributes()
            userImageView.setImageForName(userName, backgroundColor: currentTheme.onSurface12Color, circular: true, textAttributes: attributes, gradient: false)
        }
    }
    
    private func getTextAttributes() -> [NSAttributedString.Key: AnyObject]? {
        if let currentTheme = currentTheme {
            return [NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue): UIFont.inter(style: .medium, size: 12.0),
                    NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): currentTheme.onSurface12TextColor]
        }
        return nil
    }
    
    private func addAccessibility() {
        baseView.isAccessibilityElement = true
        baseView.accessibilityIdentifier = "user-details"
        baseView.accessibilityLabel = viewModel?.displayName()
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.currentTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
        userNameLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        updateUserImage()
    }
}
