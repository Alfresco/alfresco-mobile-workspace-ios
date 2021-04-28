//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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
import Photos

class PhotoGalleryViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var cameraDelegate: CameraKitCaptureDelegate?
    
    let itemsSize = CGSize(width: 76.0, height: 76.0)
    var distanceBetweenCells: CGFloat = 8.0
    
    var photoGalleryDataSource: PhotoGalleryDataSource?
    var theme: GalleryConfigurationLayout?
    
    var enableUploadButton = false {
        didSet {
            uploadButton.isUserInteractionEnabled = enableUploadButton
            uploadButton.isEnabled = enableUploadButton
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        PHPhotoLibrary.shared().register(self)
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.allowsMultipleSelection = true
        applyComponentsThemes()
        centerCells()
        enableUploadButton = false
    }
    
    // MARK: - IBActions

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func uploadButtonTapped(_ sender: UIButton) {
        photoGalleryDataSource?.fetchSelectedAssets(for: cameraDelegate)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func applyComponentsThemes() {
        guard let theme = self.theme else { return }
        view.backgroundColor = theme.surfaceColor
        closeButton.tintColor = theme.onSurface60Color
        titlelabel.textColor = theme.onSurfaceColor
        titlelabel.font = theme.headline6Font
        uploadButton.titleLabel?.font = theme.subtitle2Font
        uploadButton.setTitleColor(theme.primaryColor, for: .normal)
        uploadButton.setTitleColor(theme.onSurface15Color, for: .disabled)
    }
    
    private func centerCells() {
        let viewWidth = view.bounds.width
        let numberOfCellPerRow = Int(viewWidth / itemsSize.width)
        let remainingSpace = viewWidth / CGFloat(numberOfCellPerRow)
        let margin = remainingSpace / CGFloat(numberOfCellPerRow + 2)
        let colletionViewPadding = margin * 2
        collectionView.contentInset = UIEdgeInsets(top: 0,
                                                   left: colletionViewPadding,
                                                   bottom: 0,
                                                   right: colletionViewPadding)
        distanceBetweenCells = margin
    }
}

// MARK: - UICollectionView Delegates

extension PhotoGalleryViewController: UICollectionViewDelegateFlowLayout,
                                      UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = photoGalleryDataSource else { return 0 }
        return viewModel.numberOfAssets()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseIdentifier = String(describing: PhotoGalleryCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as? PhotoGalleryCollectionViewCell
        return cell ?? UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        guard let viewModel = photoGalleryDataSource else { return }
        if let cell = cell as? PhotoGalleryCollectionViewCell {
            let asset = viewModel.asset(for: indexPath)
            cell.asset(selected: viewModel.isAssetSelected(for: indexPath))
            cell.assest(isVideo: viewModel.isVideoAsset(asset))
            
            let targetSize = cell.assetImageViewTargetSize()
            viewModel.image(for: asset,
                            size: targetSize) { (image) in
                DispatchQueue.main.async {
                    cell.assetImageView.image = image
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = photoGalleryDataSource else { return }
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoGalleryCollectionViewCell {
            cell.asset(selected: true)
            cell.contentView.backgroundColor = theme?.primaryColor.withAlphaComponent(0.12)
            viewModel.markAssetsAs(enabled: true, for: indexPath)
            enableUploadButton = true
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didDeselectItemAt indexPath: IndexPath) {
        guard let viewModel = photoGalleryDataSource else { return }
        if let cell = collectionView.cellForItem(at: indexPath) as? PhotoGalleryCollectionViewCell {
            cell.asset(selected: false)
            viewModel.markAssetsAs(enabled: false, for: indexPath)
            enableUploadButton = viewModel.anyAssetSelected()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemsSize
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return distanceBetweenCells
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return distanceBetweenCells
    }
}

extension PhotoGalleryViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let allPhotos = photoGalleryDataSource?.allPhotoAssets {
            guard let change = changeInstance.changeDetails(for: allPhotos) else {
                return
            }

            // Keep the new fetch result for future use.
            let fetchResult = change.fetchResultAfterChanges
            photoGalleryDataSource?.allPhotoAssets = fetchResult
            if change.hasIncrementalChanges {
                // If there are incremental diffs, animate them in the collection view.
                DispatchQueue.main.async { [weak self] in
                    guard let sSelf = self else { return }

                    sSelf.collectionView.performBatchUpdates({
                        // For indexes to make sense, updates must be in this order:
                        // delete, insert, reload, move
                        if let removed = change.removedIndexes, !removed.isEmpty {
                            sSelf.collectionView.deleteItems(at: removed.map { IndexPath(item: $0,
                                                                                         section: 0) })
                        }
                        if let inserted = change.insertedIndexes, !inserted.isEmpty {
                            sSelf.collectionView.insertItems(at: inserted.map { IndexPath(item: $0,
                                                                                          section: 0) })
                        }
                        if let changed = change.changedIndexes, !changed.isEmpty {
                            sSelf.collectionView.reloadItems(at: changed.map { IndexPath(item: $0,
                                                                                         section: 0) })
                        }
                        change.enumerateMoves { fromIndex, toIndex in
                            sSelf.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                          to: IndexPath(item: toIndex, section: 0))
                        }
                    })
                }
            } else {
                // Reload the collection view if incremental diffs are not available.
                DispatchQueue.main.sync { [weak self] in
                    guard let sSelf = self else { return }

                    sSelf.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: - Storyboard Instantiable

extension PhotoGalleryViewController: CameraStoryboardInstantiable { }
