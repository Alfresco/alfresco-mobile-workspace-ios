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

class UploadFilesViewController: SystemSearchViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    let regularCellHeight: CGFloat = 54.0
    lazy var listViewModel = UploadFilesViewModel()
    weak var uploadScreenCoordinatorDelegate: UploadFilesScreenCoordinator?
    weak var tabBarScreenDelegate: TabBarScreenDelegate?

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let identifier = String(describing: ListElementCollectionViewCell.self)
        collectionView?.register(UINib(nibName: identifier,
                                       bundle: nil),
                                 forCellWithReuseIdentifier: identifier)
        
        // Sync Notification
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.handleSyncStartedNotification(notification:)),
                                               name: Notification.Name(KeyConstants.Notification.syncStarted),
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        collectionView.reloadData()
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension UploadFilesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return listViewModel.numberOfItems()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifierElement = String(describing: ListElementCollectionViewCell.self)
        guard let node = listViewModel.listNode(for: indexPath.row) else {
            return UICollectionViewCell()
        }
        
        guard let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: identifierElement,
                                     for: indexPath) as? ListElementCollectionViewCell else { return UICollectionViewCell() }
        cell.node = node
        cell.applyTheme(coordinatorServices?.themingService?.activeTheme)
        if node.nodeType == .fileLink || node.nodeType == .folderLink {
            cell.moreButton.isHidden = true
        }
        
        cell.subtitle.text = ""
        cell.disableFiles(true)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: regularCellHeight)
    }
}

// MARK: - Sync Notification
extension UploadFilesViewController {
    @objc private func handleSyncStartedNotification(notification: Notification) {
        collectionView.reloadData()
    }
}

// MARK: - Storyboard Instantiable

extension UploadFilesViewController: StoryboardInstantiable { }
