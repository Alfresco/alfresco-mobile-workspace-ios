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
            progressView.progress = 0.3
        }
    }
    
    func updateProgress() {
        let dataAccessor = UploadTransferDataAccessor()
        let pendingUploadTransfers = dataAccessor.queryAll()
        uploadingLabel.text = String(format: LocalizationConstants.AppExtension.uploadingFiles, pendingUploadTransfers.count)
    }
}
