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
import MaterialComponents.MDCProgressView

class UploadingFilesBanner: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var uploadingImage: UIImageView!
    @IBOutlet weak var uploadingLabel: UILabel!
    @IBOutlet weak var progressView: MDCProgressView!
    lazy var viewModel = UploadingFilesBannerViewModel()
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func applyTheme(_ currentTheme: PresentationTheme?) {
        if let theme = currentTheme {
            baseView.backgroundColor = theme.primaryColorVariant
            divider.backgroundColor = theme.onSurface15Color
            percentageLabel.font = theme.body2TextStyle.font
            percentageLabel.textColor = theme.onSurface60Color
            uploadingLabel.font = theme.subtitle2TextStyle.font
            uploadingLabel.textColor = theme.onSurfaceColor
        }
    }
    
    func updateProgress() {
        let totalFilesStartedUploading = appDelegate()?.totalUploadingFilesNeedsToBeSynced ?? 0
        let pendingUploadTransfers = self.queryAll()
        let progress = calculateProgress()
        
        if pendingUploadTransfers.isEmpty {
            uploadingImage.image = UIImage(named: UploadingStatusImage.done.rawValue)
            uploadingLabel.text = String(format: LocalizationConstants.AppExtension.finishedUploadingMessage, totalFilesStartedUploading)
            percentageLabel.text = "100%"
            progressView.progress = 1.0
            self.removeBanner()
        } else {
            uploadingImage.image = UIImage(named: UploadingStatusImage.uploading.rawValue)
            uploadingLabel.text = String(format: LocalizationConstants.AppExtension.uploadingFiles, pendingUploadTransfers.count)
            percentageLabel.text = String(format: "%.2f%%", progress*100.0)
            progressView.progress = progress
        }
    }
    
    func calculateProgress() -> Float {
        let totalFilesStartedUploading = appDelegate()?.totalUploadingFilesNeedsToBeSynced ?? 0
        let pendingUploadTransfers = self.queryAll().count
        let uploadedCount = totalFilesStartedUploading - pendingUploadTransfers
        let value = Float(uploadedCount)/Float(totalFilesStartedUploading)
        return value
    }
    
    func queryAll() -> [UploadTransfer] {
        let dataAccessor = UploadTransferDataAccessor()
        let pendingUploadTransfers = dataAccessor.queryAll()
        return pendingUploadTransfers
    }
    
    func removeBanner() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            SyncBannerService.removeSyncBanner()
        }
    }
}
