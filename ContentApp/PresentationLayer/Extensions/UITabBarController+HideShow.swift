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

extension UITabBarController {
    
    func setTabBarHidden(_ hidden: Bool, navigationController: UINavigationController?) {
        guard let navigationController = navigationController else { return }

        if !hidden {
            self.tabBar.isHidden = false
            self.view.frame = CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: UIConstants.ScreenHeight)

            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
                let tabBarFrame = self.tabBar.frame
                self.tabBar.frame.origin.y = navigationController.view.frame.maxY - tabBarFrame.height
                navigationController.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.7, options: .curveEaseOut) {
                let tabBarFrame = self.tabBar.frame
                self.tabBar.frame.origin.y = navigationController.view.frame.maxY + tabBarFrame.height
                navigationController.view.layoutIfNeeded()
            } completion: { _ in
                self.tabBar.isHidden = true
                let tabbarHeight = self.tabBar.frame.size.height
                self.view.frame = CGRect(x: 0, y: 0, width: UIConstants.ScreenWidth, height: UIConstants.ScreenHeight + tabbarHeight)
            }
        }
    }
}
