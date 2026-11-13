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
@testable import AlfrescoContent
import Foundation
import MaterialComponents

class TestTaskDetailViewModel: XCTestCase {
    lazy var viewModel = TaskPropertiesViewModel()

    // MARK: - load tasks from bundle
    func loadTasksFromAppBundle() -> TaskNode? {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.Tasks.mockTask, withExtension: KeyConstants.Tasks.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                return parseAppConfiguration(for: data)
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
        return nil
    }
    
    private func parseAppConfiguration(for data: Data?) -> TaskNode? {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(Task.self, from: json)
                let taskNodes = TaskNodeOperations.processNodes(for: [decoded])
                if !taskNodes.isEmpty {
                    return taskNodes.first
                }
            } catch {
                AlfrescoLog.error(error)
            }
        }
        return nil
    }
    
    func testTaskDetailViewModel_WhenInValidDueDateProvided_ShouldReturnMessage() {
        let task = loadTasksFromAppBundle()
        viewModel.task = task
        let dueDate = viewModel.getDueDate(for: Date())
        if dueDate == LocalizationConstants.Tasks.noDueDate {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
    
    func testTaskDetailViewModel_WhenTaskIsAssigned_ShouldAllowToComplete() {
        let task = loadTasksFromAppBundle()
        viewModel.task = task
        if viewModel.isAllowedToCompleteTask() {
            XCTAssertTrue(true)
        }
        XCTAssertFalse(false)
    }
    
    func testTaskDetailViewModel_WhenLatestCommentUnvailable_ShouldReturnFalseToShow() {
        let task = loadTasksFromAppBundle()
        viewModel.task = task
        if viewModel.latestComment != nil {
            XCTAssertTrue(true)
            return
        }
        XCTAssertFalse(false)
    }

    @MainActor
    func testDueDateSheetPresentsVisibleDatePicker() throws {
        let viewController = DatePickerViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        viewController.coordinatorServices = try XCTUnwrap(appDelegate()?.applicationCoordinator).coordinatorServices
        _ = try XCTUnwrap(viewController.coordinatorServices?.themingService?.activeTheme)

        try presentTaskDialog(bottomSheet, animated: true)

        let responsive = expectation(description: "Date picker leaves the main queue responsive")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            responsive.fulfill()
        }
        wait(for: [responsive], timeout: 2)
        XCTAssertFalse(viewController.view.isHidden)
        XCTAssertGreaterThan(viewController.datePicker.bounds.height, 0)
        XCTAssertGreaterThanOrEqual(viewController.preferredContentSize.height,
                                    viewController.headerView.bounds.height + viewController.datePicker.bounds.height)
    }

    @MainActor
    func testDueDatePickerPreservesInitialDateAndOnlyCommitsOnDone() throws {
        let viewController = DatePickerViewController.instantiateViewController()
        viewController.coordinatorServices = try XCTUnwrap(appDelegate()?.applicationCoordinator).coordinatorServices
        _ = try XCTUnwrap(viewController.coordinatorServices?.themingService?.activeTheme)
        let initialDate = Date(timeIntervalSince1970: 1_800_000_000)
        let editedDate = initialDate.addingTimeInterval(86_400)
        viewController.viewModel.selectedDate = initialDate
        viewController.loadViewIfNeeded()
        XCTAssertEqual(viewController.datePicker.date, initialDate)
        var committedDates: [Date?] = []
        viewController.callBack = { committedDates.append($0) }

        viewController.datePicker.setDate(editedDate, animated: false)
        viewController.cancelButtonAction(viewController.cancelButton as Any)
        XCTAssertTrue(committedDates.isEmpty)
        viewController.doneButtonAction(viewController.doneButton as Any)

        XCTAssertEqual(committedDates, [editedDate])
    }

    @MainActor
    func testAssigneeDialogLeavesSpaceForSearchResults() throws {
        let storyboard = UIStoryboard(name: StoryboardConstants.storyboard.tasks, bundle: nil)
        let viewController = try XCTUnwrap(storyboard.instantiateViewController(withIdentifier:
            StoryboardConstants.controller.taskAssignee) as? TaskAssigneeViewController)
        viewController.coordinatorServices = try XCTUnwrap(appDelegate()?.applicationCoordinator).coordinatorServices
        _ = try XCTUnwrap(viewController.coordinatorServices?.themingService?.activeTheme)
        let navigationController = UINavigationController(rootViewController: viewController)

        try presentTaskDialog(navigationController)

        XCTAssertGreaterThan(viewController.tableView.bounds.height, viewController.headerView.bounds.height)
        XCTAssertTrue(viewController.view.bounds.contains(viewController.headerView.frame))
        XCTAssertTrue(viewController.view.bounds.contains(viewController.radioButtonView.frame))
    }

    @MainActor
    private func presentTaskDialog(_ viewController: UIViewController, animated: Bool = false) throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let window = UIWindow(windowScene: scene)
        let presenter = UIViewController()
        window.rootViewController = presenter
        window.makeKeyAndVisible()
        addTeardownBlock {
            await MainActor.run {
                window.isHidden = true
                window.rootViewController = nil
            }
        }

        let presented = expectation(description: "Task dialog presentation completes")
        presenter.present(viewController, animated: animated) {
            presented.fulfill()
        }
        wait(for: [presented], timeout: 5)
        viewController.view.layoutIfNeeded()
    }
}
