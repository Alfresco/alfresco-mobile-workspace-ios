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

extension UIViewController {
    static var applicationTopMost: UIViewController? {
        return self.topMost(of: UIApplication.shared.keyWindow?.rootViewController)
    }

    static var applicationTopMostPresented: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.presentedViewController
    }

    static func topMost(of viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return topMost(of: visibleViewController)
        }

        if let presentedViewController = viewController?.presentedViewController {
            return topMost(of: presentedViewController)
        }

        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return topMost(of: selectedViewController)
        }

        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMost(of: childViewController)
            }
        }

        return viewController
    }
}
