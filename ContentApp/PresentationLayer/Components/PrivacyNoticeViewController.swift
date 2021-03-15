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
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming

class PrivacyNoticeViewController: SystemThemableViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var privacyButton: MDCButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        addLocalization()
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()

        guard let loginButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton),
              let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        privacyButton.applyContainedTheme(withScheme: loginButtonScheme)
        privacyButton.setBackgroundColor(currentTheme.onSurface5Color,
                                         for: .disabled)
        privacyButton.isUppercaseTitle = false
        privacyButton.setShadowColor(.clear, for: .normal)

        titleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        titleLabel.textAlignment = .center
        descriptionLabel.applyStyleSubtitle2OnSurface60(theme: currentTheme)
        descriptionLabel.textAlignment = .center
    }

    // MARK: - Actions

    @IBAction func privacyButtonTapped(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                  options: [:],
                                  completionHandler: nil)
    }

    @IBAction func dismissPrivacyVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Helpers

    func addLocalization() {
        titleLabel.text = LocalizationConstants.PrivacySettings.privacyPhotosTitle
        descriptionLabel.text = LocalizationConstants.PrivacySettings.privacyPhotosDescription
        privacyButton.setTitle(LocalizationConstants.PrivacySettings.privacyButton, for: .normal)
    }
}

extension PrivacyNoticeViewController: StoryboardInstantiable {}
