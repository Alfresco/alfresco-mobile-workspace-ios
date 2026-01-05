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
import AlfrescoAuth

import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialTextControls_OutlinedTextFields
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming

class FakeDoorViewController: SystemThemableViewController {
    
    weak var fakeDoorScreenCoordinatorDelegate: FakeDoorScreenCoordinatorDelegate?
    var viewModel: AskDiscoveryViewModel?

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var thumbsUpButton: UIButton!
    @IBOutlet weak var thumbsDownButton: UIButton!
    @IBOutlet weak var thankYouLabel: UILabel!
    @IBOutlet weak var closeButton: MDCButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        AnalyticsManager.shared.didTapAskDiscovery()
        navigationController?.setNavigationBarHidden(false, animated: true)
        thankYouLabel.isHidden = true
        thumbsUpButton.setImage(UIImage(named: "ic-thumbs-up"), for: .normal)
        thumbsDownButton.setImage(UIImage(named: "ic-thumbs-down"), for: .normal)
        addLocalization()
        addAccessibility()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    func addLocalization() {
        self.title = LocalizationConstants.ScreenTitles.askAnAgent
        self.titleLabel.text = LocalizationConstants.AskDiscovery.fakeDoorTitle
        self.subtitleLabel.text = LocalizationConstants.AskDiscovery.fakeDoorSubtitle
        self.thankYouLabel.text = LocalizationConstants.AskDiscovery.fakeDoorThankYou
        self.closeButton.setTitle(LocalizationConstants.AskDiscovery.fakeDoorClose, for: .normal)
    }
    
    private func addAccessibility() {

        titleLabel.accessibilityLabel = LocalizationConstants.AskDiscovery.fakeDoorTitle
        titleLabel.accessibilityIdentifier = "knowledge-discovery-title"

        subtitleLabel.accessibilityLabel = LocalizationConstants.AskDiscovery.fakeDoorSubtitle
        subtitleLabel.accessibilityIdentifier = "knowledge-discovery-sub-title"
        
        thumbsUpButton.accessibilityIdentifier = "thumbs-up-button"
        thumbsUpButton.accessibilityIdentifier = LocalizationConstants.AskDiscovery.fakeDoorLike
        
        thumbsDownButton.accessibilityIdentifier = "thumbs-down-button"
        thumbsDownButton.accessibilityIdentifier = LocalizationConstants.AskDiscovery.fakeDoorDislike

        thankYouLabel.accessibilityLabel = LocalizationConstants.AskDiscovery.fakeDoorThankYou
        thankYouLabel.accessibilityIdentifier = "thank-you"
        
        closeButton.accessibilityIdentifier = "close-button"
        closeButton.accessibilityLabel = LocalizationConstants.AskDiscovery.fakeDoorClose
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let closeButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .closeButton), let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }

        view.backgroundColor = currentTheme.surfaceColor
        let image = UIImage(color: currentTheme.surfaceColor,
                            size: navigationController?.navigationBar.bounds.size)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = currentTheme.surfaceColor
        navigationController?.navigationBar.tintColor = currentTheme.onSurface70Color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = currentTheme.surfaceColor
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: currentTheme.headline6TextStyle.font,
             NSAttributedString.Key.foregroundColor: currentTheme.onSurfaceColor]
        
        titleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        titleLabel.textAlignment = .center
        subtitleLabel.applyStyleSubtitle3OnSurface60(theme: currentTheme)
        subtitleLabel.textAlignment = .center
        thankYouLabel.applyStyleSubtitle2OonSurfaceOrangeColor(theme: currentTheme)
        thankYouLabel.textAlignment = .center
        
        closeButton.applyContainedTheme(withScheme: closeButtonScheme)
        closeButton.isUppercaseTitle = false
        closeButton.setShadowColor(.clear, for: .normal)
        closeButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
        
        let themingService = coordinatorServices?.themingService
        switch themingService?.getThemeMode() {
        case .light:
            thumbsUpButton.tintColor = UIColor.black
            thumbsDownButton.tintColor = UIColor.black
        case .dark:
            thumbsUpButton.tintColor = .white
            thumbsDownButton.tintColor = .white
        default:
            let style = UIScreen.main.traitCollection.userInterfaceStyle
            thumbsUpButton.tintColor = (style == .dark) ? .white : .black
            thumbsDownButton.tintColor = (style == .dark) ? .white : .black
        }
    }
    
    // MARK: - Button Action
    @IBAction func thumbsUpButtonAction(_ sender: Any) {
        thumbsUpButton.setImage(UIImage(named: "ic-thumbs-up-selected"), for: .normal)
        thumbsDownButton.setImage(UIImage(named: "ic-thumbs-down"), for: .normal)
        thankYouLabel.isHidden = false
        AnalyticsManager.shared.didTapThumbsUpAskDiscovery()
    }
    
    @IBAction func thumbsDownButtonAction(_ sender: Any) {
        thumbsDownButton.setImage(UIImage(named: "ic-thumbs-down-selected"), for: .normal)
        thumbsUpButton.setImage(UIImage(named: "ic-thumbs-up"), for: .normal)
        thankYouLabel.isHidden = false
        AnalyticsManager.shared.didTapThumbsDownAskDiscovery()
    }
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension FakeDoorViewController: AskDiscoveryViewModelDelegate {}

// MARK: - Storyboard Instantiable

extension FakeDoorViewController: StoryboardInstantiable { }
