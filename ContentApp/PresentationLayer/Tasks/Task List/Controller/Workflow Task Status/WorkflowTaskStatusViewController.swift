//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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
import AlfrescoContent
import MaterialComponents

class WorkflowTaskStatusViewController: SystemSearchViewController, MDCBottomSheetControllerDelegate {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dropDownImageView: UIImageView!
        
    var viewModel: WorkflowTaskStatusViewModel { return controller.viewModel }
    lazy var controller: WorkflowTaskStatusController = { return WorkflowTaskStatusController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()

    // MARK: - View Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.navigationItem.setHidesBackButton(true, animated: true)
        applyLocalization()
        addBackButton()
        addAccessibility()
        AnalyticsManager.shared.pageViewEvent(for: Event.Page.workflowTaskStatusScreen)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func applyLocalization() {
        self.title = LocalizationConstants.Tasks.status
    }
    
    private func addAccessibility() {
    }
    
    // MARK: - Public Helpers
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        statusLabel.applyStyleBody1OnSurface(theme: currentTheme)
        dropDownImageView.tintColor = currentTheme.onSurfaceColor
        view.backgroundColor = currentTheme.surfaceColor
    }
    
    private func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.accessibilityIdentifier = "backButton"
        backButton.accessibilityLabel = LocalizationConstants.Accessibility.back
        backButton.frame = CGRect(x: 0.0, y: 0.0,
                                  width: 30.0,
                                    height: 30.0)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.layer.masksToBounds = true
        backButton.addTarget(self,
                               action: #selector(backButtonAction),
                               for: UIControl.Event.touchUpInside)
        backButton.setImage(UIImage(named: "ic-back"),
                              for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: backButton)
        searchBarButtonItem.accessibilityIdentifier = "backBarButton"
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: 30.0)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: 30.0)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = searchBarButtonItem
    }
    
    // MARK: - Back Button Action
    @objc func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectStatusButtonAction(_ sender: Any) {
        print("select status button action")
        
        let viewController = SearchListComponentViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.delegate = self
        viewController.coordinatorServices = coordinatorServices
        viewController.listViewModel.isRadioList = true
        viewController.listViewModel.taskChip = chip
        viewController.taskFilterCallBack = { (selectedChip, isBackButtonTapped) in
            if isBackButtonTapped {
               //  self.resetChip()
            } else if let selectedChip = selectedChip {
               // self.updateChip(for: selectedChip, and: indexPath)
            }
        }
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
    }
    
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        
    }
}


/*
// Radio Component
private func showListSelectorComponent(for chip: TaskChipItem, and indexPath: IndexPath) {
   
    let viewController = SearchListComponentViewController.instantiateViewController()
    let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
    bottomSheet.dismissOnDraggingDownSheet = false
    bottomSheet.delegate = self
    viewController.coordinatorServices = coordinatorServices
    viewController.listViewModel.isRadioList = true
    viewController.listViewModel.taskChip = chip
    viewController.taskFilterCallBack = { (selectedChip, isBackButtonTapped) in
        if isBackButtonTapped {
             self.resetChip()
        } else if let selectedChip = selectedChip {
            self.updateChip(for: selectedChip, and: indexPath)
        }
    }
    self.navigationController?.present(bottomSheet, animated: true, completion: nil)
}

// MARK: - Bottom sheet delegate
extension TasksSortAndFilterView: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        self.resetChip()
    }
    
    func resetChip() {
        if let selectedChip = self.viewModel.selectedChip {
            if let index = self.viewModel.chips.firstIndex(where: {$0.chipId == selectedChip.chipId}) {
                let selectedValue = selectedChip.selectedValue ?? ""
                if selectedValue.isEmpty {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.deSelectChipCollectionCell(for: indexPath)
                    reloadChipCollectionWithoutScroll()
                }
            }
        }
    }
}
*/
