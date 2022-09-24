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

class TaskAssigneeViewController: SystemThemableViewController {
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var progressView: MDCProgressView!
    @IBOutlet weak var nameRadioImageView: UIImageView!
    @IBOutlet weak var nameTitleLabel: UILabel!
    @IBOutlet weak var emailRadioImageView: UIImageView!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var radioButtonsViewDivider: UIView!
    @IBOutlet weak var nameButton: MDCButton!
    @IBOutlet weak var emailButton: MDCButton!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: TaskAssigneeViewModel { return controller.viewModel }
    lazy var controller: TaskAssigneeController = { return TaskAssigneeController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        progressView.progress = 0
        progressView.mode = .indeterminate
        registerCells()
        applyLocalization()
        addAccessibility()
        updateUIComponents()
        controller.buildViewModel()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        updateTheme()
        view.isHidden = false
    }
    
    func updateTheme() {
        let activeTheme = coordinatorServices?.themingService?.activeTheme
        progressView.progressTintColor = activeTheme?.primaryT1Color
        progressView.trackTintColor = activeTheme?.primary30T1Color
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
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.taskAssignee, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.taskAssignee)
    }
    
    // MARK: - Apply Themes, Accessibility and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        dismissButton.setImage(UIImage(named: "ic-back"), for: .normal)
        dismissButton.tintColor = currentTheme.onSurface60Color
        divider.backgroundColor = currentTheme.onSurface15Color
        nameTitleLabel.applyStyleBody2OnSurface(theme: currentTheme)
        emailLabel.applyStyleBody2OnSurface(theme: currentTheme)
        radioButtonsViewDivider.backgroundColor = currentTheme.onSurface15Color
    }
    
    private func applyLocalization() {
        nameTitleLabel.text = LocalizationConstants.EditTask.byName
        emailLabel.text = LocalizationConstants.EditTask.byEmail
    }
    
    func addAccessibility() {
        progressView.isAccessibilityElement = false
        dismissButton.accessibilityLabel = LocalizationConstants.Accessibility.closeButton
        dismissButton.accessibilityIdentifier = "cancel"
        nameButton.accessibilityLabel = nameTitleLabel.text
        nameButton.accessibilityIdentifier = "searchByName"
       
        emailButton.accessibilityLabel = emailLabel.text
        emailButton.accessibilityIdentifier = "searchByEmail"

        if let dismissButton = dismissButton, let nameButton = nameButton, let emailButton = emailButton {
            self.accessibilityElements = [dismissButton, nameButton, emailButton]
        }
    }
    
    func startLoading() {
        progressView?.startAnimating()
        progressView?.setHidden(false, animated: true)
    }

    func stopLoading() {
        progressView?.stopAnimating()
        progressView?.setHidden(true, animated: false)
    }
    
    // MARK: - Button Actions
    @IBAction func dismissButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func searchByNameButtonAction(_ sender: Any) {
        viewModel.isSearchByName = true
        updateUIComponents()
    }
    
    @IBAction func searchByEmailButtonAction(_ sender: Any) {
        viewModel.isSearchByName = false
        updateUIComponents()
    }
    
    private func updateUIComponents() {
        nameRadioImageView.image = viewModel.searchByNameImage
        emailRadioImageView.image = viewModel.searchByEmailImage
    }
    
    
    // MARK: - Set up Bindings
    private func setupBindings() {
        
        /* observer loader */
        viewModel.isLoading.addObserver { [weak self] (isLoading) in
            guard let sSelf = self else { return }
            if isLoading {
                sSelf.startLoading()
            } else {
                sSelf.stopLoading()
            }
        }
        
        /* observing rows */
        viewModel.rowViewModels.addObserver() { [weak self] (rows) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                sSelf.tableView.reloadData()
            }
        }
    }
}

// MARK: - Table View Data Source and Delegates
extension TaskAssigneeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.rowViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowViewModel = viewModel.rowViewModels.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: controller.cellIdentifier(for: rowViewModel), for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowViewModel)
        }
        
        if let theme = coordinatorServices?.themingService {
            if cell is TaskAssigneeTableViewCell {
                (cell as? TaskAssigneeTableViewCell)?.applyTheme(with: theme)
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
