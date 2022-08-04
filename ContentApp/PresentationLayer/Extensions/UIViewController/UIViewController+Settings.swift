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
    private static var _settingsButton = [String: UIButton]()

    var settingsButton: UIButton {
        get {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: UIButton.self))
            return UIViewController._settingsButton[tmpAddress] ?? UIButton()
        }
        set(newValue) {
            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: UIButton.self))
            UIViewController._settingsButton[tmpAddress] = newValue
        }
    }

    func addSettingsButton(action: Selector, target: Any?) {
        let settingsButtonAspectRatio: CGFloat = 30.0
        settingsButton = UIButton(type: .custom)
        settingsButton.accessibilityIdentifier = "settingsButton"
        settingsButton.accessibilityLabel = LocalizationConstants.Accessibility.userProfile
        settingsButton.frame = CGRect(x: 0.0, y: 0.0,
                                      width: settingsButtonAspectRatio,
                                      height: settingsButtonAspectRatio)
        addAvatarInSettingsButton()
        settingsButton.imageView?.contentMode = .scaleAspectFill
        settingsButton.imageView?.layer.cornerRadius = settingsButtonAspectRatio / 2
        settingsButton.layer.masksToBounds = true
        settingsButton.clipsToBounds = false
        settingsButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        settingsBarButtonItem.accessibilityIdentifier = "settingsBarButton"
        let currWidth = settingsBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: settingsButtonAspectRatio)
        currWidth?.isActive = true
        let currHeight = settingsBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: settingsButtonAspectRatio)
        currHeight?.isActive = true

        self.navigationItem.leftBarButtonItem = settingsBarButtonItem
    }

    func addAvatarInSettingsButton() {
        let avatarImage = ProfileService.getAvatar(completionHandler: { [weak self] image in
            guard let sSelf = self else { return }

            if let fetchedImage = image {
                sSelf.settingsButton.setImage(fetchedImage, for: .normal)
            }
        })
        settingsButton.setImage(avatarImage, for: .normal)
    }
}
