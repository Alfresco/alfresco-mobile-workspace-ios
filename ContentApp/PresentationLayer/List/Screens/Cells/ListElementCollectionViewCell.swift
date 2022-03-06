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
}

class ListElementCollectionViewCell: ListSelectableCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var syncStatusImageView: UIImageView!
    @IBOutlet weak var disableView: UIView!
    weak var delegate: ListElementCollectionViewCellDelegate?
    var currentTheme: PresentationTheme?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    var node: ListNode? {
        didSet {
            guard let node = node else { return }

            title.text = node.title
            subtitle.text = node.path
            iconImageView.image = FileIcon.icon(for: node)
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
        iconImageView.tintColor = currentTheme.onSurface60Color
        moreButton.tintColor = currentTheme.onSurface60Color
        syncStatusImageView.tintColor = currentTheme.onSurface60Color
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
}
