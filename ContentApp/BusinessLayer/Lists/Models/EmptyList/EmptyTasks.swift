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

import Foundation
import UIKit

// MARK: - Empty Tasks
struct EmptyTasks: EmptyListProtocol {
    var icon = UIImage(named: "ic-empty-list-tasks")
    var title = LocalizationConstants.Tasks.noTasksFound
    var description = LocalizationConstants.Tasks.createTaskMessage
}

// MARK: - Tasks not configured
struct TasksNotConfigured: EmptyListProtocol {
    var icon = UIImage(named: "ic-empty-list-tasks")
    var title = LocalizationConstants.Tasks.noTasksFound
    var description = LocalizationConstants.Tasks.notConfiguredMessage
}

// MARK: - Empty Workflows
struct EmptyWorkflows: EmptyListProtocol {
    var icon = UIImage(named: "ic-empty-list-tasks")
    var title = LocalizationConstants.Workflows.noWorkflowFound
    var description = LocalizationConstants.Workflows.startWorkflowMessage
}

// MARK: - Workflows not configured
struct WorkflowsNotConfigured: EmptyListProtocol {
    var icon = UIImage(named: "ic-empty-list-tasks")
    var title = LocalizationConstants.Workflows.noWorkflowFound
    var description = LocalizationConstants.Workflows.notConfiguredMessage
}

// MARK: - Empty Attach Files
struct EmptyAttachFiles: EmptyListProtocol {
    var icon = UIImage(named: "ic-empty-list-recents")
    var title = LocalizationConstants.Tasks.noAttachedFilesPlaceholder
    var description = String(format: LocalizationConstants.Workflows.attachFilesDescription, KeyConstants.FileSize.workflowFileSize)
    
}
