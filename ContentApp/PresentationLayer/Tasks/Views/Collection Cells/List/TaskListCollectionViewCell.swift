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
    @IBOutlet weak var dateLabel: UILabel!
    var currentTheme: PresentationTheme?
    lazy var viewModel = TaskPropertiesViewModel()
    lazy var workflowViewModel = WorkflowViewModel()

    override func awakeFromNib() {
        super.awakeFromNib()
        priorityView.layer.cornerRadius = priorityView.frame.size.height/2.0
        addAccessibility()
    }
    
    private func addAccessibility() {
        title.accessibilityLabel = LocalizationConstants.Accessibility.title
        subtitle.accessibilityLabel = LocalizationConstants.Accessibility.assignee
        dateLabel.accessibilityLabel = LocalizationConstants.Workflows.createdDate
        priorityLabel.accessibilityLabel = LocalizationConstants.Accessibility.priority
        
        title.accessibilityIdentifier = "title"
        subtitle.accessibilityIdentifier = "sub-title"
        priorityLabel.accessibilityIdentifier = "priority"
        dateLabel.accessibilityIdentifier = "created-date"
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        backgroundColor = currentTheme.surfaceColor
        title.applyStyleBody1OnSurface(theme: currentTheme)
        title.lineBreakMode = .byTruncatingTail
        subtitle.applyStyleCaptionOnSurface60(theme: currentTheme)
        subtitle.lineBreakMode = .byTruncatingHead
        dateLabel.applyStyleCaptionOnSurface60(theme: currentTheme)
        dateLabel.lineBreakMode = .byTruncatingHead
        priorityLabel.applyStyleSubtitle2OnSurface(theme: currentTheme)
    }
    
    func setupData(for task: TaskNode?) {
        guard let task = task, let currentTheme = currentTheme else { return }
        viewModel.task = task
        
        title.text = viewModel.taskName
        subtitle.text = viewModel.userName
        dateLabel.text = viewModel.getCreatedDate(for: viewModel.createdDate)
        
        priorityLabel.textColor = UIFunction.getPriorityValues(for: currentTheme, taskPriority: viewModel.taskPriority).textColor
        priorityView.backgroundColor = UIFunction.getPriorityValues(for: currentTheme, taskPriority: viewModel.taskPriority).backgroundColor
        priorityLabel.text = UIFunction.getPriorityValues(for: currentTheme, taskPriority: viewModel.taskPriority).priorityText
        
        title.accessibilityValue = title.text
        subtitle.accessibilityValue = subtitle.text
        dateLabel.accessibilityValue = dateLabel.text
        priorityLabel.accessibilityValue = priorityLabel.text
    }
    
    func setupWorkflowData(for workflow: WorkflowNode?) {
        guard let workflow = workflow else { return }
        workflowViewModel.workflow = workflow
        
        title.text = workflowViewModel.workflowName
        subtitle.text = workflowViewModel.userName
        dateLabel.text = viewModel.getCreatedDate(for: workflowViewModel.started)

        priorityView.isHidden = true
        priorityLabel.text = nil
        
        title.accessibilityValue = title.text
        subtitle.accessibilityValue = subtitle.text
    }
}
