//
// Copyright (C) 2005-2025 Alfresco Software Limited.
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
    private static var _askDiscoveryButton = [String: UIButton]()

    var askDiscoveryButton: UIButton {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: UIButton.self))
            return UIViewController._askDiscoveryButton[tmpAddress] ?? UIButton()
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: UIButton.self))
            UIViewController._askDiscoveryButton[tmpAddress] = newValue
        }
    }

    func addAskDiscoveryButton(action: Selector, target: Any?) {
        let askDiscoveryButtonAspectRatio: CGFloat = 30.0
        askDiscoveryButton = UIButton(type: .custom)
        askDiscoveryButton.accessibilityIdentifier = "askDiscoveryButton"
        askDiscoveryButton.accessibilityLabel = LocalizationConstants.Accessibility.askDiscovery
        askDiscoveryButton.frame = CGRect(x: 0.0, y: 0.0,
                                      width: askDiscoveryButtonAspectRatio,
                                      height: askDiscoveryButtonAspectRatio)
        askDiscoveryButton.imageView?.contentMode = .scaleAspectFill
        askDiscoveryButton.layer.masksToBounds = true
        askDiscoveryButton.clipsToBounds = false
        askDiscoveryButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        askDiscoveryButton.setImage(UIImage(named: "ic-ask"),
                            for: .normal)

        let askDiscoveryButtonBarButtonItem = UIBarButtonItem(customView: askDiscoveryButton)
        askDiscoveryButtonBarButtonItem.accessibilityIdentifier = "askDiscoveryButtonBarButton"
        let currWidth = askDiscoveryButtonBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: askDiscoveryButtonAspectRatio)
        currWidth?.isActive = true
        let currHeight = askDiscoveryButtonBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: askDiscoveryButtonAspectRatio)
        currHeight?.isActive = true

        self.navigationItem.rightBarButtonItem = askDiscoveryButtonBarButtonItem
    }
}
