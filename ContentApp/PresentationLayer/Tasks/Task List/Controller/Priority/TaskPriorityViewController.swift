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

class TaskPriorityViewController: SystemThemableViewController {
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var lowView: UIView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var mediumView: UIView!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var highView: UIView!
    @IBOutlet weak var highLabel: UILabel!
    lazy var viewModel = TaskPriorityViewModel()
    typealias TaskPriorityCallBack = (_ priority: Int) -> Void
    var callBack: TaskPriorityCallBack?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        applyTheme()
        applyLocalization()
        addAccessibility()
        updateSelectedValue()
    }
    
    func addAccessibility() {
        dismissButton.accessibilityLabel = LocalizationConstants.Accessibility.closeButton
        dismissButton.accessibilityIdentifier = "cancel"
        
        titleLabel.accessibilityLabel = LocalizationConstants.Accessibility.title
        titleLabel.accessibilityValue = LocalizationConstants.Accessibility.priority
        titleLabel.accessibilityIdentifier = "title"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        view.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }
    
    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    // MARK: - Apply Themes and Localization
     func applyTheme() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        divider.backgroundColor = currentTheme.onSurface12Color
        dismissButton.tintColor = currentTheme.onSurfaceColor
        titleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        
        lowView.layer.cornerRadius = lowView.frame.size.height / 2.0
        lowView.layer.borderWidth = 1.0
        lowView.layer.borderColor = currentTheme.onSurface12Color.cgColor
        lowLabel.applyStyleBody2OnSurface(theme: currentTheme)
        lowLabel.textAlignment = .center
        
        mediumView.layer.cornerRadius = mediumView.frame.size.height / 2.0
        mediumView.layer.borderWidth = 1.0
        mediumView.layer.borderColor = currentTheme.onSurface12Color.cgColor
        mediumLabel.applyStyleBody2OnSurface(theme: currentTheme)
        mediumLabel.textAlignment = .center
        
        highView.layer.cornerRadius = highView.frame.size.height / 2.0
        highView.layer.borderWidth = 1.0
        highView.layer.borderColor = currentTheme.onSurface12Color.cgColor
        highLabel.applyStyleBody2OnSurface(theme: currentTheme)
        highLabel.textAlignment = .center
    }
    
    private func applyLocalization() {
        titleLabel.text = LocalizationConstants.Accessibility.priority
        lowLabel.text = LocalizationConstants.Tasks.low
        mediumLabel.text = LocalizationConstants.Tasks.medium
        highLabel.text = LocalizationConstants.Tasks.high
    }
    
    // MARK: - Button Actions
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func lowButtonAction(_ sender: Any) {
        viewModel.priority = 0
        dismissControllerWithCallBack()
    }
    
    @IBAction func mediumButtonAction(_ sender: Any) {
        viewModel.priority = 4
        dismissControllerWithCallBack()
    }
    
    @IBAction func highButtonAction(_ sender: Any) {
        viewModel.priority = 8
        dismissControllerWithCallBack()
    }
    
    private func updateSelectedValue() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        if viewModel.taskPriority == .low {
           
            lowLabel.textColor = currentTheme.taskSuccessTextColor
            lowView.backgroundColor = currentTheme.taskSuccessContainer
            resetPriority(view: mediumView, label: mediumLabel)
            resetPriority(view: highView, label: highLabel)
        } else if viewModel.taskPriority == .medium {
           
            mediumLabel.textColor = currentTheme.taskWarningTextColor
            mediumView.backgroundColor = currentTheme.taskWarningContainer
            resetPriority(view: lowView, label: lowLabel)
            resetPriority(view: highView, label: highLabel)
        } else if viewModel.taskPriority == .high {
           
            highLabel.textColor = currentTheme.taskErrorTextColor
            highView.backgroundColor = currentTheme.taskErrorContainer
            resetPriority(view: lowView, label: lowLabel)
            resetPriority(view: mediumView, label: mediumLabel)
        }
    }
    
    private func resetPriority(view: UIView, label: UILabel) {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        view.backgroundColor = .clear
        label.textColor = currentTheme.onSurfaceColor
    }
    
    private func dismissControllerWithCallBack() {
        updateSelectedValue()
        self.callBack?(viewModel.priority)
        self.dismiss(animated: true, completion: nil)
    }
}
