//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

protocol ListElementCollectionViewCellDelegate: AnyObject {
    func moreButtonTapped(for element: ListNode?,
                          in cell: ListElementCollectionViewCell)
    
    func longTapGestureActivated(for element: ListNode?,
                                 in cell: ListElementCollectionViewCell)
}

class ListElementCollectionViewCell: ListSelectableCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var syncStatusImageView: UIImageView!
    @IBOutlet weak var disableView: UIView!
    @IBOutlet weak var checkBoxImageView: UIImageView!
    weak var delegate: ListElementCollectionViewCellDelegate?
    var currentTheme: PresentationTheme?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        disableView.isAccessibilityElement = false
        addLongTapGesture()
    }

    var node: ListNode? {
        didSet {
            guard let node = node else { return }

            title.text = node.title
            subtitle.text = node.path
            iconImageView.image = FileIcon.icon(for: node)
            addAccessibility(for: node)
            setAccessibilitySequence()
        }
    }

    var syncStatus: ListEntrySyncStatus = .undefined {
        didSet {
            let showSyncStatus = (syncStatus != .undefined && syncStatus != .uploaded)
            syncStatusImageView.isHidden = !showSyncStatus
            syncStatusImageView.image = showSyncStatus ? UIImage(named: syncStatus.rawValue) : nil
            
            if node?.markedFor == .upload {
                applyLayoutForUploading()
            } else {
                applyLayoutForDownloading()
            }
            addAccessibilityForSyncStatusImageView()
        }
    }

    func applyTheme(_ currentTheme: PresentationTheme?, isDisable: Bool = false) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        backgroundColor = currentTheme.surfaceColor
        title.applyStyleBody1OnSurface(theme: currentTheme)
        title.lineBreakMode = .byTruncatingTail
        subtitle.applyStyleCaptionOnSurface60(theme: currentTheme)
        subtitle.lineBreakMode = .byTruncatingHead
        iconImageView.tintColor = currentTheme.onSurface70Color
        moreButton.tintColor = currentTheme.onSurface70Color
        checkBoxImageView.image = UIImage(named: "ic-checkbox-unchecked")
        syncStatusImageView.tintColor = currentTheme.onSurface70Color
        disableFiles(isDisable: isDisable)
    }
    
    private func disableFiles(isDisable: Bool) {
        guard let currentTheme = self.currentTheme else { return }
        if !isDisable {
            self.isUserInteractionEnabled = true
            disableView.backgroundColor = .clear
            disableView.alpha = 0
        } else {
            self.isUserInteractionEnabled = false
            disableView.backgroundColor = currentTheme.surface60Color
            disableView.alpha = 1
            checkBoxImageView.isHidden = true
        }
    }
    
    func disableFilesToMove(_ currentTheme: PresentationTheme?, node: ListNode?) {
        guard let currentTheme = currentTheme else { return }
        checkBoxImageView.isHidden = true
        if node?.nodeType != .folder {
            self.isUserInteractionEnabled = false
            disableView.backgroundColor = currentTheme.surface60Color
            disableView.alpha = 1
        } else {
            self.isUserInteractionEnabled = true
            disableView.backgroundColor = .clear
            disableView.alpha = 0
        }
    }
    
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        delegate?.moreButtonTapped(for: node, in: self)
    }
    
    // MARK: - Private Methods
    
    private func applyLayoutForUploading() {
        switch syncStatus {
        case .pending:
            syncStatusImageView.image = UIImage(named: ListEntrySyncStatus.uploaded.rawValue)
        case .inProgress:
            startRotateSyncIcon()
        default:
            subtitle.text = ""
            stopRotateSyncIcon()
        }
    }
    
    private func applyLayoutForDownloading() {
        switch syncStatus {
        case .error:
            subtitle.text = LocalizationConstants.Labels.syncFailed
            stopRotateSyncIcon()
        case .inProgress:
            subtitle.text = LocalizationConstants.Labels.syncing
            startRotateSyncIcon()
        default:
            stopRotateSyncIcon()
        }
    }
    
    private func startRotateSyncIcon() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: .pi * 2.0)
        rotationAnimation.duration = 3.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = .infinity
        syncStatusImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    private func stopRotateSyncIcon() {
        syncStatusImageView.layer.removeAnimation(forKey: "rotationAnimation")
    }
    
    func addAccessibility(for node: ListNode) {
        title.accessibilityLabel = LocalizationConstants.Accessibility.title
        title.accessibilityValue = node.title
        subtitle.accessibilityLabel = LocalizationConstants.TextFieldPlaceholders.path
        subtitle.accessibilityValue = node.path
        moreButton.accessibilityLabel = LocalizationConstants.Accessibility.more
    }
    
    private func addAccessibilityForSyncStatusImageView() {
        var syncStatusValue = LocalizationConstants.Accessibility.undefined
        switch syncStatus {
        case .markedForOffline:
            syncStatusValue = LocalizationConstants.Accessibility.markedForOffline
        case .error:
            syncStatusValue = LocalizationConstants.Accessibility.error
        case .pending:
            syncStatusValue = LocalizationConstants.Accessibility.pending
        case .inProgress:
            syncStatusValue = LocalizationConstants.Accessibility.inProgress
        case .downloaded:
            syncStatusValue = LocalizationConstants.Accessibility.downloaded
        case .uploaded:
            syncStatusValue = LocalizationConstants.Accessibility.uploaded
        default:
            syncStatusValue = LocalizationConstants.Accessibility.undefined
        }
        syncStatusImageView.accessibilityLabel = LocalizationConstants.Accessibility.syncStatus
        syncStatusImageView.accessibilityValue = syncStatusValue
    }
    
    func setAccessibilitySequence() {
        if let tTitle = title, let tMoreButton = moreButton {
            self.accessibilityElements = [tTitle, tMoreButton]
        }
        
        let subTitleText = subtitle.text ?? ""
        if subtitle != nil && !subTitleText.isEmpty {
            self.accessibilityElements?.append(subtitle!)
        }
        
        if syncStatusImageView != nil && !syncStatusImageView.isHidden {
            self.accessibilityElements?.append(syncStatusImageView!)
        }
    }
}

// MARK: - Tap Gesture and Long Tap Gesture
extension ListElementCollectionViewCell {
    
    private func addLongTapGesture() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        longPressRecognizer.minimumPressDuration = 0.3
        longPressRecognizer.delaysTouchesBegan = true
        self.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func longPressed(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            delegate?.longTapGestureActivated(for: node, in: self)
        }
    }
}

// MARK: - Multiple file selection
extension ListElementCollectionViewCell {
    
    func setMultipleFileSelection(isMultipleFileSelectionEnabled: Bool) {
        let isMoveFilesAndFolderFlow = appDelegate()?.isMoveFilesAndFolderFlow ?? false
        if isMultipleFileSelectionEnabled && !isMoveFilesAndFolderFlow {
            moreButton.isHidden = true
            checkBoxImageView.isHidden = false
        } else {
            backgroundColor = self.currentTheme?.surfaceColor
            moreButton.isHidden = false
            moreButton.isEnabled = true
            checkBoxImageView.isHidden = true
        }
    }
    
    func setMultipleSelectedItem(for nodes: [ListNode], tappedNode: ListNode?) {
        guard let tappedNode = tappedNode else { return }
        if nodes.contains(tappedNode) {
            backgroundColor = self.currentTheme?.primary24T1Color
            checkBoxImageView.image = UIImage(named: "ic-checkbox-checked")
        } else {
            backgroundColor = self.currentTheme?.surfaceColor
            checkBoxImageView.image = UIImage(named: "ic-checkbox-unchecked")
        }
    }
}
