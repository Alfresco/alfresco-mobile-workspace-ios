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
import MaterialComponents

class StartableWorkflowsViewController: SystemThemableViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewContraintHeight: NSLayoutConstraint!
    
    lazy var viewModel = StartableWorkflowsViewModel()
    private var activityIndicator = MDCActivityIndicator()
    let actionMenuCellHeight: CGFloat = 55.0
    let emptyViewHeight: CGFloat = 200.0
    var didSelectAction: ((WFlowAppDefinitions) -> Void)?

    // MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: true)
        viewModel.services = coordinatorServices ?? CoordinatorServices()
        viewModel.delegate = self
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        
        registerCells()
        activityIndicator.startAnimating()
        fetchAppDefinitions()
        view.addSubview(activityIndicator)
        addLocalization()
    }
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.surfaceColor
        activityIndicator.cycleColors = [currentTheme.primaryVariantT1Color]
        
        headerImageView.tintColor = currentTheme.onSurface70Color
        headerTitleLabel.applyStyleBody1OnSurface(theme: currentTheme)
        divider.backgroundColor = currentTheme.onSurface12Color
    }
    
    func addLocalization() {
        headerTitleLabel.text = LocalizationConstants.Workflows.selectWorkflow
    }
    
    private func fetchAppDefinitions() {
        viewModel.fetchWorkflowsList {[weak self] appDefinitions, error in
            guard let sSelf = self else { return }
            sSelf.collectionView.isHidden = false
            sSelf.collectionView?.reloadData()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let numberOfActions = viewModel.numberOfActions()
        if numberOfActions == 0 {
            collectionViewContraintHeight.constant = emptyViewHeight
        } else {
            collectionViewContraintHeight.constant = numberOfActions * actionMenuCellHeight
        }
        activityIndicator.center = CGPoint(x: view.center.x,
                                           y: view.center.y)
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
    
    // MARK: - Private Utils
    
    private func registerCells() {
        collectionView.register(UINib(nibName: CellConstants.CollectionCells.runTimeAppDefinition, bundle: nil), forCellWithReuseIdentifier: CellConstants.CollectionCells.runTimeAppDefinition)
        
        collectionView.register(UINib(nibName: CellConstants.CollectionCells.emptyWorkflowList, bundle: nil), forCellWithReuseIdentifier: CellConstants.CollectionCells.emptyWorkflowList)
    }
}

// MARK: - UIColectionView Delegates

extension StartableWorkflowsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let numberOfActions = Int(viewModel.numberOfActions())
        return numberOfActions == 0 ? 1: numberOfActions
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let numberOfActions = Int(viewModel.numberOfActions())
        if numberOfActions == 0 {
            let reuseIdentifier = String(describing: EmptyWorkflowListCollectionViewCell.self)
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                             for: indexPath) as? EmptyWorkflowListCollectionViewCell {
                cell.applyTheme(coordinatorServices?.themingService?.activeTheme)
                cell.setupData()
                return cell
            }
        } else {
            let reuseIdentifier = String(describing: WorkflowListCollectionViewCell.self)
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                             for: indexPath) as? WorkflowListCollectionViewCell {
                let appDefinition = viewModel.appDefinitions[indexPath.row]
                cell.applyTheme(coordinatorServices?.themingService?.activeTheme)
                cell.setupData(for: appDefinition)
                return cell
            }
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfActions = Int(viewModel.numberOfActions())
        if numberOfActions == 0 {
            return CGSize(width: collectionView.frame.width, height: emptyViewHeight)
        } else {
            return CGSize(width: collectionView.frame.width, height: actionMenuCellHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let numberOfActions = Int(viewModel.numberOfActions())
        if numberOfActions != 0 {
            let appDefinition = viewModel.appDefinitions[indexPath.row]
            self.didSelectAction?(appDefinition)
            self.dismiss(animated: true)
        }
    }
}

// MARK: - ActionMenuViewModel Delegate

extension StartableWorkflowsViewController: ActionMenuViewModelDelegate {
    func finishedLoadingActions() {
        let numberOfActions = viewModel.numberOfActions()
        if numberOfActions == 0 {
            collectionViewContraintHeight.constant = emptyViewHeight
        } else {
            collectionViewContraintHeight.constant = numberOfActions * actionMenuCellHeight
        }
        collectionView.reloadData()
        activityIndicator.stopAnimating()
    }
}
