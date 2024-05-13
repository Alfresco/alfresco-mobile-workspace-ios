//
// Copyright (C) 2005-2024 Alfresco Software Limited.
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

protocol ActionListViewControllerDelegate: AnyObject {
    func actionListViewController(_ viewController: ActionListViewController, didSelectItem selectedItem: Outcome)
}

class ActionListViewController: SystemThemableViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightTableView: NSLayoutConstraint!
    let maxHeightTableView: CGFloat =  UIConstants.ScreenHeight - 270.0
    var outcomes = [Outcome]()
    let rowViewModels = Observable<[RowViewModel]>([])
    weak var delegate: ActionListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCells()
        buildViewModel()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        baseView.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        tableView.estimatedRowHeight = 1000
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
    
    func cellIdentifier(for viewModel: RowViewModel) -> String {
        switch viewModel {
        case is OutcomesTableViewCellViewModel:
            return OutcomesTableViewCell.cellIdentifier()
        default:
            fatalError("Unexpected view model type: \(viewModel)")
        }
    }
    
    // MARK: - Apply Themes and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.surfaceColor
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.outcomesTableViewCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.outcomesTableViewCell)
    }
    
    func buildViewModel() {
        var rowViewModels = [RowViewModel]()
        for outcome in outcomes {
            let cellVM = ourcomesCellVM(for: outcome)
            rowViewModels.append(cellVM)
        }
        self.rowViewModels.value = rowViewModels
    }
    
    // MARK: - CheckBox
    private func ourcomesCellVM(for outcomes: Outcome) -> OutcomesTableViewCellViewModel {
        let rowVM = OutcomesTableViewCellViewModel(outcome: outcomes)
        return rowVM
    }
    
    // Function to handle item selection
    func handleItemSelection(_ selectedItem: Outcome) {
        delegate?.actionListViewController(self, didSelectItem: selectedItem)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Table View Data Source and Delegates
extension ActionListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.rowViewModels.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let rowViewModel = self.rowViewModels.value[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier(for: rowViewModel), for: indexPath)
        if let cell = cell as? CellConfigurable {
            cell.setup(viewModel: rowViewModel)
        }
        (cell as? OutcomesTableViewCell)?.outcomesBtn.tag = indexPath.row
        (cell as? OutcomesTableViewCell)?.outcomesBtn.addTarget(self, action: #selector(outcomeButtonAction(button:)), for: .touchUpInside)
        applyTheme(cell)
        cell.layoutIfNeeded()
        return cell
    }
    
    @objc func outcomeButtonAction(button: UIButton) {
        let selectedOutcome = outcomes[button.tag]
        handleItemSelection(selectedOutcome)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.view.layoutSubviews()
        DispatchQueue.main.async {
            self.heightTableView?.constant = ( self.tableView.contentSize.height < self.maxHeightTableView ) ? self.tableView.contentSize.height : self.maxHeightTableView
        }
        self.view.layoutIfNeeded()
    }
    
    fileprivate func applyTheme(_ cell: UITableViewCell) {
        if let themeCell = cell as? CellThemeApplier, let theme = coordinatorServices?.themingService {
            themeCell.applyCellTheme(with: theme)
        }
    }
}
