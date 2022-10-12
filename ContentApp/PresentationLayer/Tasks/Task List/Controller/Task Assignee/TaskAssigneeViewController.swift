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
    @IBOutlet weak var radioButtonsViewDivider: UIView!
    @IBOutlet weak var nameButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var viewModel: TaskAssigneeViewModel { return controller.viewModel }
    lazy var controller: TaskAssigneeController = { return TaskAssigneeController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    typealias TaskAssigneeCallBack = (_ assignee: TaskNodeAssignee) -> Void
    var callBack: TaskAssigneeCallBack?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)

        viewModel.services = coordinatorServices ?? CoordinatorServices()
        setAccessibilitySequence()
        progressView.progress = 0
        progressView.mode = .indeterminate
        registerCells()
        applyLocalization()
        addAccessibility()
        updateUIComponents()
        controller.buildViewModel()
        setupBindings()
        if !UIAccessibility.isVoiceOverRunning {
            searchTextField.becomeFirstResponder()
        }
        searchTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
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
        applyButtonTheme(theme: currentTheme)
        radioButtonsViewDivider.backgroundColor = currentTheme.onSurface15Color
        searchTextField.font = currentTheme.subtitle1TextStyle.font
        searchTextField.textColor = currentTheme.onSurfaceColor
        
    }
    
    private func applyButtonTheme(theme: PresentationTheme) {
        
        emailButton.setTitleColor(theme.onSurfaceColor, for: .normal)
        emailButton.titleLabel?.font = theme.subtitle1TextStyle.font
        emailButton.titleLabel?.add(characterSpacing: theme.body2TextStyle.letterSpacing, lineHeight: theme.body2TextStyle.lineHeight)
        nameButton.setTitleColor(theme.onSurfaceColor, for: .normal)
        nameButton.titleLabel?.font = theme.subtitle1TextStyle.font
        nameButton.titleLabel?.add(characterSpacing: theme.body2TextStyle.letterSpacing, lineHeight: theme.body2TextStyle.lineHeight)
    }
    
    private func applyLocalization() {
        emailButton.setTitle(LocalizationConstants.EditTask.byEmail, for: UIControl.State.normal)
        nameButton.setTitle(LocalizationConstants.EditTask.byName, for: UIControl.State.normal)
        searchTextField.placeholder = LocalizationConstants.EditTask.searchPlaceholder
    }
    
    func addAccessibility() {
        progressView.isAccessibilityElement = false
        dismissButton.accessibilityLabel = LocalizationConstants.Accessibility.back
        dismissButton.accessibilityIdentifier = "cancel"
        nameButton.accessibilityIdentifier = "searchByName"
        emailButton.accessibilityIdentifier = "searchByEmail"
        searchTextField.accessibilityLabel = LocalizationConstants.EditTask.searchPlaceholder
    }
    
    private func setAccessibilitySequence() {
        dismissButton.isAccessibilityElement = true
        searchTextField.isAccessibilityElement = true
        nameButton.isAccessibilityElement = true
        emailButton.isAccessibilityElement = true
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
        if viewModel.isSearchByName == true {return}
        viewModel.isSearchByName = true
        updateUIComponents()
    }
    
    @IBAction func searchByEmailButtonAction(_ sender: Any) {
        if viewModel.isSearchByName == false {return}
        viewModel.isSearchByName = false
        updateUIComponents()
    }
    
    private func updateUIComponents() {
        nameButton.setImage(viewModel.searchByNameImage, for: .normal)
        emailButton.setImage(viewModel.searchByEmailImage, for: .normal)
        resetUserList()
        editingChanged()
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
        
        /* observing users */
        viewModel.users.addObserver() { [weak self] (users) in
            guard let sSelf = self else { return }
            sSelf.controller.buildViewModel()
        }
        
        /* observing rows */
        viewModel.rowViewModels.addObserver() { [weak self] (rows) in
            guard let sSelf = self else { return }
            DispatchQueue.main.async {
                sSelf.tableView.reloadData()
            }
        }
        
        /* observe did select user action */
        controller.didSelectUserAction = {[weak self] (assignee) in
            guard let sSelf = self else { return }
            sSelf.didSelectAssignee(with: assignee)
        }
    }
    
    private func didSelectAssignee(with assignee: TaskNodeAssignee) {
        callBack?(assignee)
        self.dismiss(animated: true, completion: nil)
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

// MARK: - UITextField Delegate

extension TaskAssigneeViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        editingChanged()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        resetUserList()
        return true
    }
    
    @objc func editingChanged() {
        if viewModel.searchTimer != nil {
            viewModel.searchTimer?.invalidate()
            viewModel.searchTimer = nil
        }
        
        let text = (searchTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        viewModel.searchText = text
        viewModel.searchTimer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(searchForKeyword(_:)), userInfo: nil, repeats: false)
    }
    
    @objc func searchForKeyword(_ timer: Timer) {
        searchRequest()
    }
    
    func searchRequest() {
        let text = (searchTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            resetUserList()
            return
        } else if viewModel.isSearchByName && viewModel.minimumCharactersToSearch > text.count {
            return
        } else if !viewModel.isSearchByName && !text.isValidEmail {
            return
        }
        
        var searchText = viewModel.searchText
        var email: String?
        if !viewModel.isSearchByName {
            searchText = nil
            email = viewModel.searchText
        }
        
        viewModel.searchUser(with: searchText, email: email) {[weak self] assignee, error in
            guard let sSelf = self else { return }
            sSelf.viewModel.users.value = assignee
        }
    }
    
    private func resetUserList() {
        viewModel.users.value.removeAll()
    }
}
