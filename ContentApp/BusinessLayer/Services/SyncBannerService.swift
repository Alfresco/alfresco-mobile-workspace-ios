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

class SyncBannerService: CoordinatorServices {

    class func showSyncBannerIfNecessary(on tabBarMainViewController: TabBarMainViewController?, with themingService: PresentationTheme?) {
        if let window = appDelegate()?.window, let tabBarMainViewController = tabBarMainViewController, let uploadingFilesBanner: UploadingFilesBanner = .fromNib() {
            if appDelegate()?.uploadingFilesBanner == nil {
                let yAxis =  tabBarMainViewController.tabBar.frame.origin.y - 71.5
                uploadingFilesBanner.frame = CGRect(x: 0, y: yAxis, width: window.frame.size.width, height: 64.0)
                uploadingFilesBanner.applyTheme(themingService)
                tabBarMainViewController.view.addSubview(uploadingFilesBanner)
                appDelegate()?.uploadingFilesBanner = uploadingFilesBanner
            }
        }
    }
    
    class func removeSyncBanner() {
        if let uploadingFilesBanner = appDelegate()?.uploadingFilesBanner {
            uploadingFilesBanner.removeFromSuperview()
            appDelegate()?.uploadingFilesBanner = nil
        }
    }
}
