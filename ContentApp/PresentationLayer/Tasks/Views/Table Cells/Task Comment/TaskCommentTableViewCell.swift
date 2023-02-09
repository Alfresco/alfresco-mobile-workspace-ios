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

class TaskCommentTableViewCell: UITableViewCell, CellConfigurable {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var userImageBaseView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    var viewModel: TaskCommentTableCellViewModel?
    var currentTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageBaseView.layer.cornerRadius = userImageBaseView.frame.size.height/2.0
    }
    
    func setup(viewModel: RowViewModel) {
        guard let viewModel = viewModel as? TaskCommentTableCellViewModel else { return }
        self.viewModel = viewModel
        
        updateUserImage()
        dateLabel.text = viewModel.dateString
        userNameLabel.text = viewModel.commentUserName
        commentLabel.numberOfLines = viewModel.isShowReadMore ? 4:0
        commentLabel.text = viewModel.comment
        DispatchQueue.main.async {
            self.commentLabel.text = self.textWithReadMore()
        }
        
        addAccessibility()
        addTapGesture()
    }
    
    private func addTapGesture() {
        let isShowReadMore = viewModel?.isShowReadMore ?? false
        if isShowReadMore {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            baseView.addGestureRecognizer(tap)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.didSelectCommentAction?()
    }
    
    private func updateUserImage() {
        if let userName = viewModel?.userName, let currentTheme = currentTheme {
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
        dateLabel.isAccessibilityElement = true
        dateLabel.accessibilityIdentifier = "date"
        dateLabel.accessibilityLabel = LocalizationConstants.Accessibility.date
        dateLabel.accessibilityValue = dateLabel.text
        
        userNameLabel.isAccessibilityElement = true
        userNameLabel.accessibilityIdentifier = "user-name"
        userNameLabel.accessibilityLabel = LocalizationConstants.Accessibility.userName
        userNameLabel.accessibilityValue = userNameLabel.text
        
        commentLabel.isAccessibilityElement = true
        commentLabel.accessibilityIdentifier = "comment"
        commentLabel.accessibilityLabel = LocalizationConstants.Accessibility.commentTitle
        commentLabel.accessibilityValue = commentLabel.text
    }
    
    // MARK: - Apply Themes and Localization
    func applyTheme(with service: MaterialDesignThemingService?) {
        guard let currentTheme = service?.activeTheme else { return }
        self.currentTheme = currentTheme
        self.backgroundColor = currentTheme.surfaceColor
        userNameLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
        dateLabel.applyStyleSubtitle2OnSurface30(theme: currentTheme)
        commentLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        updateUserImage()
    }
    
    private func textWithReadMore() -> String? {
        if commentLabel.maxNumberOfLines >= commentLabel.numberOfVisibleLines {
            let stringArray = self.commentLabel.lines
            var commentText = ""
            for text in stringArray {
                commentText = String(format: "%@%@", commentText, text)
            }
            
            commentText = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
            commentText = String(format: "%@...", commentText)
            return commentText
        }
        return viewModel?.comment
    }
}
