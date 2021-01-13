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
        settingsButton = UIButton(type: .custom)
        settingsButton.frame = CGRect(x: 0.0, y: 0.0, width: accountSettingsButtonHeight, height: accountSettingsButtonHeight)
        addAvatarInSettingsButton()
        settingsButton.imageView?.contentMode = .scaleAspectFill
        settingsButton.layer.cornerRadius = accountSettingsButtonHeight / 2
        settingsButton.layer.masksToBounds = true
        settingsButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        applyTheme()

        let settingsBarButtonItem = UIBarButtonItem(customView: settingsButton)
        let currWidth = settingsBarButtonItem.customView?.widthAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
        currWidth?.isActive = true
        let currHeight = settingsBarButtonItem.customView?.heightAnchor.constraint(equalToConstant: accountSettingsButtonHeight)
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

    func applyTheme() {
        let repository = ApplicationBootstrap.shared().repository
        let themingService = repository.service(of: MaterialDesignThemingService.identifier) as? MaterialDesignThemingService
        guard let currentTheme = themingService?.activeTheme else { return }
        settingsButton.tintColor = currentTheme.onSurface60Color
    }
}
