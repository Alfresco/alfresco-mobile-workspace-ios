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
import MaterialComponents

class TitleTableViewCell: UITableViewCell, CellConfigurable {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var editImageView: UIImageView!
    @IBOutlet weak var widthEditImage: NSLayoutConstraint!
    var viewModel: TitleTableCellViewModel?
    var activeTheme: PresentationTheme?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        baseView.isAccessibilityElement = false
        titleLabel.isAccessibilityElement = true
        subTitleLabel.isAccessibilityElement = true
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        subTitleLabel.isUserInteractionEnabled = true
        subTitleLabel.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.editTaskAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let isViewAllButtonVisible = viewModel?.isViewAllButtonVisible ?? false
        let isHideReadMore = viewModel?.isHideReadMore ?? false
        if isViewAllButtonVisible && isHideReadMore == false {
            viewModel?.didSelectReadMoreAction?()
        }
    }
    
    @objc func editTaskAction(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.didSelectEditTitle?()
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TitleTableCellViewModel else { return }
        self.viewModel = viewModel
        titleLabel.text = viewModel.title
        subTitleLabel.numberOfLines = viewModel.isHideReadMore ? 0:3
        subTitleLabel.text = viewModel.subTitle
        if viewModel.isHideReadMore == false {
            DispatchQueue.main.async {
                self.subTitleLabel.attributedText = self.textWithReadMore()
            }
        }
        editImageView.isHidden = viewModel.isHideEditImage
        widthEditImage.constant = viewModel.widthEditImageView
        addAccessibility()
    }
    
    private func addAccessibility() {        
        titleLabel.accessibilityIdentifier = "title"
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleLabel.accessibilityValue = titleLabel.text
        
        subTitleLabel.accessibilityIdentifier = "sub-title"
        subTitleLabel.accessibilityLabel = LocalizationConstants.Accessibility.descriptionTitle
        subTitleLabel.accessibilityValue = subTitleLabel.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
       
        self.activeTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
        titleLabel.applyStyleSubtitle1OnSurface(theme: currentTheme)
        subTitleLabel.applyStyleSubtitle2OnSurface30(theme: currentTheme)
        
        editImageView.image = UIImage(named: "ic-edit-icon")
        editImageView.tintColor = currentTheme.onSurfaceColor
    }
    
    private func textWithReadMore() -> NSAttributedString? {
        if subTitleLabel.maxNumberOfLines >= subTitleLabel.numberOfVisibleLines {
            viewModel?.isViewAllButtonVisible = true
            let stringArray = self.subTitleLabel.lines
            var commentText = ""
            for text in stringArray {
                commentText = String(format: "%@%@", commentText, text)
            }
            
            commentText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            commentText = String(format: "%@...", commentText)
            let text = getAttributedText(description: commentText, readMoreText: LocalizationConstants.Tasks.viewAllTitle)
            return text
        }
        viewModel?.isViewAllButtonVisible = false
        return getAttributedText(description: viewModel?.subTitle, readMoreText: nil)
    }
    
    private func getAttributedText(description: String?, readMoreText: String?) -> NSAttributedString? {
        
        guard let activeTheme = activeTheme else { return nil }

        let descAttribute = [NSAttributedString.Key.font: activeTheme.subtitle2TextStyle.font, NSAttributedString.Key.foregroundColor: activeTheme.onSurface30Color]
        let readMoreAttribute = [NSAttributedString.Key.font: activeTheme.subtitle2TextStyle.font, NSAttributedString.Key.foregroundColor: activeTheme.primaryT1Color]

        var attributedString1 = NSMutableAttributedString()
        if let description = description {
            attributedString1 = NSMutableAttributedString(string: description, attributes: descAttribute)
        }
        
        if let readMoreText = readMoreText {
            let attributedString2 = NSMutableAttributedString(string: readMoreText, attributes: readMoreAttribute)
            attributedString1.append(NSMutableAttributedString(string: " ", attributes: readMoreAttribute))
            attributedString1.append(attributedString2)
        }
        
        return attributedString1
    }
}
