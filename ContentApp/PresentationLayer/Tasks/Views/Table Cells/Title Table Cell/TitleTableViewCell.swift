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
        editImageView.isAccessibilityElement = true
        addTapGesture()
    }
    
    private func addTapGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        subTitleLabel.isUserInteractionEnabled = true
        subTitleLabel.addGestureRecognizer(tapGestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        tap.numberOfTapsRequired = 1
        titleLabel.isUserInteractionEnabled = true
        titleLabel.addGestureRecognizer(tap)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.editTaskAction(_:)))
        tapGesture.numberOfTapsRequired = 1
        editImageView.isUserInteractionEnabled = true
        editImageView.addGestureRecognizer(tapGesture)
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        let isHideReadMore = viewModel?.isHideReadMore ?? false
        let isEnableTapOnTitle = viewModel?.isEnableTapOnTitle ?? false
        let isEnableTapOnSubTitle = viewModel?.isEnableTapOnSubTitle ?? false

        if (isEnableTapOnTitle || isEnableTapOnSubTitle) && !isHideReadMore {
            viewModel?.didSelectReadMoreAction?()
        }
    }
    
    @objc func editTaskAction(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.didSelectEditTitle?()
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TitleTableCellViewModel else { return }
        self.viewModel = viewModel
        editImageView.isHidden = viewModel.isHideEditImage
        widthEditImage.constant = viewModel.widthEditImageView
        
        titleLabel.numberOfLines = viewModel.isHideReadMore ? 0:2
        titleLabel.text = viewModel.title
        
        subTitleLabel.numberOfLines = viewModel.isHideReadMore ? 0:3
        subTitleLabel.text = viewModel.subTitle
       
        if viewModel.isHideReadMore == false {
            DispatchQueue.main.async {
                self.subTitleLabel.attributedText = self.textWithReadMore()
                self.titleLabel.text = self.titleTextWithDots(for: self.titleLabel)
            }
        }
        
        addAccessibility()
    }
    
    private func addAccessibility() {
        titleLabel.accessibilityTraits = .staticText
        titleLabel.accessibilityIdentifier = "title"
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleLabel.accessibilityValue = titleLabel.text
        
        subTitleLabel.accessibilityTraits = .staticText
        subTitleLabel.accessibilityIdentifier = "sub-title"
        subTitleLabel.accessibilityLabel = LocalizationConstants.Accessibility.descriptionTitle
        subTitleLabel.accessibilityValue = subTitleLabel.text
        
        editImageView.accessibilityTraits = .button
        editImageView.accessibilityLabel = LocalizationConstants.General.edit
        editImageView.accessibilityIdentifier = "edit"
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
            let stringArray = subTitleLabel.lines
            var commentText = ""
            for text in stringArray {
                commentText = String(format: "%@%@", commentText, text)
            }
            
            commentText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            commentText = String(format: "%@...", commentText)
            let text = getAttributedText(description: commentText, readMoreText: LocalizationConstants.Tasks.viewAllTitle)
            viewModel?.isEnableTapOnTitle = true
            return text
        }
        viewModel?.isEnableTapOnTitle = false
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
    
    private func titleTextWithDots(for label: UILabel) -> String? {
        if label.maxNumberOfLines >= label.numberOfVisibleLines {
            let stringArray = label.lines
            var commentText = ""
            for text in stringArray {
                commentText = String(format: "%@%@", commentText, text)
            }
            
            commentText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            commentText = String(format: "%@...", commentText)
            viewModel?.isEnableTapOnSubTitle = true
            return commentText
        }
        viewModel?.isEnableTapOnSubTitle = false
        return label.text
        
    }
}
