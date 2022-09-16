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

class TaskDescriptionDetailViewController: SystemSearchViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel: TaskDescriptionDetailViewModel { return controller.viewModel }
    lazy var controller: TaskDescriptionDetailController = { return TaskDescriptionDetailController( currentTheme: coordinatorServices?.themingService?.activeTheme) }()
    let buttonWidth = 30.0
    
    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.services = coordinatorServices ?? CoordinatorServices()
        addBackButton()
        registerCells()
        controller.buildViewModel()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    private func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.accessibilityIdentifier = "backButton"
        backButton.frame = CGRect(x: 0.0, y: 0.0,
                                  width: buttonWidth,
                                    height: buttonWidth)
        backButton.imageView?.contentMode = .scaleAspectFill
        backButton.layer.masksToBounds = true
        backButton.addTarget(self,
                               action: #selector(backButtonTapped),
                               for: UIControl.Event.touchUpInside)
        backButton.setImage(UIImage(named: "ic-close"),
                              for: .normal)

        let searchBarButtonItem = UIBarButtonItem(customView: backButton)
        searchBarButtonItem.accessibilityIdentifier = "backBarButton"
        let currWidth = searchBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: buttonWidth)
        currWidth?.isActive = true
        let currHeight = searchBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: buttonWidth)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = searchBarButtonItem
    }
    
    func registerCells() {
        self.tableView.register(UINib(nibName: CellConstants.TableCells.titleCell, bundle: nil), forCellReuseIdentifier: CellConstants.TableCells.titleCell)
    }
}


// MARK: - Table View Data Source and Delegates
extension TaskDescriptionDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
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
            if cell is TitleTableViewCell {
                (cell as? TitleTableViewCell)?.applyTheme(with: theme)
            }
        }
        
        cell.layoutIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
