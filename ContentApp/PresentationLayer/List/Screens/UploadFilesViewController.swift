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
import MaterialComponents.MaterialActivityIndicator
import MaterialComponents.MaterialProgressView
import AlfrescoContent

class UploadFilesViewController: SystemSearchViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!
    @IBOutlet weak var listActionButton: MDCButton!

    let regularCellHeight: CGFloat = 54.0
    var listViewModel: ListComponentViewModel?
    weak var uploadScreenCoordinatorDelegate: UploadFilesScreenCoordinator?
    weak var tabBarScreenDelegate: TabBarScreenDelegate?
    private let listBottomInset: CGFloat = 70.0
    private var kvoConnectivity: NSKeyValueObservation?
    var shouldEnableListButton = true

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let listViewModel = self.listViewModel else { return }
        listViewModel.delegate = self

        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier,
                                       bundle: nil),
                                 forCellWithReuseIdentifier: identifier)
        
        // Sync Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleSyncStartedNotification(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.syncStarted),
                                               object: nil)
        
        listActionButton.isHidden = !listViewModel.shouldDisplayListActionButton()
        listActionButton.isUppercaseTitle = false
        listActionButton.setTitle(listViewModel.listActionTitle(), for: .normal)
        listActionButton.layer.cornerRadius = listActionButton.frame.height / 2
        
        if listViewModel.shouldDisplayListActionButton() {
            collectionView.contentInset = UIEdgeInsets(top: 0,
                                                       left: 0,
                                                       bottom: listBottomInset,
                                                       right: 0)
        }
        
        emptyListView.isHidden = true
        getPendingUploads()
        observeConnectivity()
        listActionButton.superview?.bringSubviewToFront(listActionButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if coordinatorServices?.syncService?.syncServiceStatus != .idle {
            setListActionButtonStatus(enable: false)
            reloadCollection()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        reloadCollection()
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme
        else { return }
        emptyListTitle.applyeStyleHeadline6OnSurface(theme: currentTheme)
        emptyListTitle.textAlignment = .center
        emptyListSubtitle.applyStyleBody2OnSurface60(theme: currentTheme)
        emptyListSubtitle.textAlignment = .center
        
        listActionButton.backgroundColor = currentTheme.primaryT1Color
        listActionButton.tintColor = currentTheme.onPrimaryColor
        listActionButton.setTitleFont(currentTheme.subtitle2TextStyle.font, for: .normal)
    }
    
    @IBAction func listActionButtonTapped(_ sender: Any) {
        listViewModel?.performListAction()
    }
    
    // MARK: Connectivity Helpers
    
    private func observeConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        kvoConnectivity = connectivityService?.observe(\.status,
                                                       options: [.new],
                                                       changeHandler: { [weak self] (_, _) in
                                                        guard let sSelf = self else { return }
                                                        sSelf.handleConnectivity()
                                                        sSelf.reloadCollection()
                                                       })
    }
    
    private func handleConnectivity() {
        let connectivityService = coordinatorServices?.connectivityService
        setListActionButtonStatus(enable: connectivityService?.hasInternetConnection() ?? false)
        reloadCollection()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension UploadFilesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listViewModel?.model.numberOfItems(in: section) ?? 0
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifierElement = String(describing: ListElementCollectionViewCell.self)
        guard let node = listViewModel?.model.listNode(for: indexPath), let listViewModel = self.listViewModel else {
            return UICollectionViewCell()
        }
        
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: identifierElement,
                                     for: indexPath) as? ListElementCollectionViewCell else { return UICollectionViewCell() }
        
        cell.node = node
        cell.applyTheme(coordinatorServices?.themingService?.activeTheme, isDisable: true)
        cell.syncStatus = (listViewModel.model as! UploadNodesModel).syncStatusForNode(at: indexPath, and: shouldEnableListButton)

        if listViewModel.shouldDisplaySubtitle(for: indexPath) == false {
            cell.subtitle.text = ""
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: regularCellHeight)
    }
}

// MARK: - ListComponentViewModelDelegate
extension UploadFilesViewController: ListComponentViewModelDelegate {
    func didUpdateListActionState(enable: Bool) {
        setListActionButtonStatus(enable: enable)
    }
}

// MARK: - Sync Notification
extension UploadFilesViewController {
    func getPendingUploads() {
        guard let listViewModel = self.listViewModel else { return }
        listViewModel.model.rawListNodes = getListNodes()
        reloadCollection()
        showEmptyList()
    }
    
    func showEmptyList() {
        guard let listViewModel = self.listViewModel else { return }
        let isListEmpty = listViewModel.model.isEmpty()
        if isListEmpty {
            DispatchQueue.main.async {
                self.emptyListView.isHidden = false
                let emptyList = listViewModel.emptyList()
                self.emptyListImageView.image = emptyList.icon
                self.emptyListTitle.text = emptyList.title
                self.emptyListSubtitle.text = emptyList.description
                self.setListActionButtonStatus(enable: false)
            }
        }
    }
    
    @objc private func handleSyncStartedNotification(notification: Notification) {
        getPendingUploads()
    }

    func getListNodes() -> [ListNode] {
        let items = self.queryAll()
        return items.map({$0.listNode()})
    }
    
    func queryAll() -> [UploadTransfer] {
        let dataAccessor = UploadTransferDataAccessor()
        let pendingUploadTransfers = dataAccessor.queryAll()
        return pendingUploadTransfers
    }
    
    func reloadCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func setListActionButtonStatus(enable: Bool) {
        guard let listViewModel = self.listViewModel else { return }
        let isListEmpty = listViewModel.model.isEmpty()
        if isListEmpty || enable == false {
            self.listActionButton.isEnabled = false
            self.shouldEnableListButton = self.listActionButton.isEnabled
        } else {
            self.listActionButton.isEnabled = true
            self.shouldEnableListButton = self.listActionButton.isEnabled
        }
    }
}

// MARK: - Storyboard Instantiable

extension UploadFilesViewController: StoryboardInstantiable { }
