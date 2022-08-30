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

import XCTest
@testable import ContentApp

class TestTaskDetailViewModel: XCTestCase {
    lazy var viewModel = TaskPropertiesViewModel()

    
    
    
    private func createTask() {
        {
          "id": "76",
          "name": "Task 19",
          "description": "",
          "category": null,
          "assignee": {
            "id": 16,
            "firstName": "Demo",
            "lastName": "User",
            "email": "demo@alfresco.com"
          },
          "created": "2022-08-30T08:06:43.783+0000",
          "dueDate": null,
          "endDate": null,
          "duration": null,
          "priority": 9,
          "parentTaskId": null,
          "parentTaskName": null,
          "processInstanceId": null,
          "processInstanceName": null,
          "processDefinitionId": null,
          "processDefinitionName": null,
          "processDefinitionDescription": null,
          "processDefinitionKey": null,
          "processDefinitionCategory": null,
          "processDefinitionVersion": 0,
          "processDefinitionDeploymentId": null,
          "formKey": null,
          "processInstanceStartUserId": null,
          "initiatorCanCompleteTask": false,
          "deactivateUserTaskReassignment": false,
          "adhocTaskCanBeReassigned": false,
          "taskDefinitionKey": null,
          "executionId": null,
          "memberOfCandidateGroup": false,
          "memberOfCandidateUsers": false,
          "managerOfCandidateGroup": false
        }
    }
    
}
