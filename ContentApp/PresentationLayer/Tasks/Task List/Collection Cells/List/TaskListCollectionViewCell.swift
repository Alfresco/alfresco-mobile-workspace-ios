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

class TaskListCollectionViewCell: ListSelectableCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var priorityView: UIView!
    @IBOutlet weak var priorityLabel: UILabel!
    var currentTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
        priorityView.layer.cornerRadius = priorityView.frame.size.height/2.0
        addAccessibility()
    }
    
    private func addAccessibility() {
        title.accessibilityLabel = LocalizationConstants.Accessibility.title
        subtitle.accessibilityLabel = LocalizationConstants.Accessibility.assignee
        priorityLabel.accessibilityLabel = LocalizationConstants.Accessibility.priority
        
        title.accessibilityIdentifier = "title"
        subtitle.accessibilityIdentifier = "sub-title"
        priorityLabel.accessibilityIdentifier = "priority"
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        backgroundColor = currentTheme.surfaceColor
        title.applyStyleBody1OnSurface(theme: currentTheme)
        title.lineBreakMode = .byTruncatingTail
        subtitle.applyStyleCaptionOnSurface60(theme: currentTheme)
        subtitle.lineBreakMode = .byTruncatingHead
        priorityLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
    }
    
    func setupData(for task: TaskNode?) {
        title.text = task?.name
        subtitle.text = userName(for: task)
        applyStyleCaptionOnPriority(for: task)
        
        title.accessibilityValue = title.text
        subtitle.accessibilityValue = subtitle.text
        priorityLabel.accessibilityValue = priorityLabel.text
    }
    
    func userName(for task: TaskNode?) -> String? {
        let firstName = task?.assignee?.firstName ?? ""
        let lastName = task?.assignee?.lastName ?? ""
        return String(format: "%@ %@", firstName, lastName)
    }
    
    func applyStyleCaptionOnPriority(for task: TaskNode?) {
        if let currentTheme = currentTheme {
            let priority = task?.priority ?? 0
            var textColor: UIColor = currentTheme.taskErrorTextColor
            var backgroundColor: UIColor = currentTheme.taskErrorContainer
            var priorityText = LocalizationConstants.Tasks.low
           
            if priority >= 0 && priority <= 3 { // low
                textColor = currentTheme.taskSuccessTextColor
                backgroundColor = currentTheme.taskSuccessContainer
                priorityText = LocalizationConstants.Tasks.low
            } else if priority >= 4 && priority <= 7 { // medium
                textColor = currentTheme.taskWarningTextColor
                backgroundColor = currentTheme.taskWarningContainer
                priorityText = LocalizationConstants.Tasks.medium
            } else { // high
                textColor = currentTheme.taskErrorTextColor
                backgroundColor = currentTheme.taskErrorContainer
                priorityText = LocalizationConstants.Tasks.high
            }
            priorityLabel.textColor = textColor
            priorityView.backgroundColor = backgroundColor
            priorityLabel.text = priorityText
        }
    }
}
