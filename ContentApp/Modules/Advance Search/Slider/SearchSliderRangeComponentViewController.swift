//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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
import AlfrescoContent
import MaterialComponents.MaterialButtons
import MaterialComponents.MaterialButtons_Theming
import MaterialComponents.MaterialSlider

class SearchSliderRangeComponentViewController: SystemThemableViewController {
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var slider: MDCSlider!
    @IBOutlet weak var dividerSlider: UIView!
    @IBOutlet weak var applyButton: MDCButton!
    @IBOutlet weak var resetButton: MDCButton!
    lazy var sliderViewModel = SearchSliderRangeComponentViewModel()
    var callback: SearchComponentCallBack?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.cornerRadius = UIConstants.cornerRadiusDialog
        baseView.layer.cornerRadius = UIConstants.cornerRadiusDialog
        view.isHidden = true
        hideKeyboardWhenTappedAround()
        applyLocalization()
        applyComponentsThemes()
        setupSlider()
        applyButton.accessibilityIdentifier = "applyActionButton-sliderComponent"
        resetButton.accessibilityIdentifier = "resetActionButton-sliderComponent"
    }
    
    func setupSlider() {
        slider.minimumValue = sliderViewModel.min
        slider.maximumValue = sliderViewModel.max
        slider.trackHeight = 4.0
        slider.thumbRadius = 16.0
        slider.isDiscrete = true
        slider.value = sliderViewModel.value
        slider.numberOfDiscreteValues = sliderViewModel.numberOfDiscreteValues
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        view.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }
    
    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width,
                                height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: .defaultHigh, verticalFittingPriority: .defaultLow)
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    // MARK: - Apply Themes and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .dialogButton),
              let bigButtonScheme = coordinatorServices?.themingService?.containerScheming(for: .loginBigButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        headerTitleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)
        dismissButton.tintColor = currentTheme.onSurfaceColor
        divider.backgroundColor = currentTheme.onSurface12Color
        dividerSlider.backgroundColor = currentTheme.onSurface12Color
        
        applyButton.applyContainedTheme(withScheme: buttonScheme)
        applyButton.isUppercaseTitle = false
        applyButton.setShadowColor(.clear, for: .normal)
        applyButton.layer.cornerRadius = UIConstants.cornerRadiusDialog

        resetButton.applyContainedTheme(withScheme: bigButtonScheme)
        resetButton.setBackgroundColor(currentTheme.onSurface5Color, for: .normal)
        resetButton.isUppercaseTitle = false
        resetButton.setShadowColor(.clear, for: .normal)
        resetButton.setTitleColor(currentTheme.onSurfaceColor, for: .normal)
        resetButton.layer.cornerRadius = UIConstants.cornerRadiusDialog
         
        slider.trackBackgroundColor = currentTheme.onSurface5Color
        slider.setTrackFillColor(currentTheme.onPrimaryColor, for: .normal)
        slider.setThumbColor(currentTheme.onPrimaryColor, for: .normal)
        slider.valueLabelBackgroundColor = currentTheme.onSurface5Color
        slider.valueLabelTextColor = currentTheme.onSurfaceColor
    }
    
    private func applyLocalization() {
        headerTitleLabel.text = sliderViewModel.title
        applyButton.setTitle(LocalizationConstants.AdvanceSearch.apply, for: .normal)
        resetButton.setTitle(LocalizationConstants.AdvanceSearch.reset, for: .normal)
    }
    
    @IBAction func dismissComponentButtonAction(_ sender: Any) {
        self.callback?(self.sliderViewModel.selectedCategory, self.sliderViewModel.queryBuilder, true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        sliderViewModel.applyFilter(with: slider.value)
        self.callback?(self.sliderViewModel.selectedCategory, self.sliderViewModel.queryBuilder, false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {
        sliderViewModel.applyFilter(with: 0)
        self.callback?(self.sliderViewModel.selectedCategory, self.sliderViewModel.queryBuilder, false)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Storyboard Instantiable
extension SearchSliderRangeComponentViewController: SearchComponentsStoryboardInstantiable { }

