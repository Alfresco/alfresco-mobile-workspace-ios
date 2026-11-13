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
import MaterialComponents

class DatePickerViewController: SystemThemableViewController {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var cancelButton: MDCButton!
    @IBOutlet weak var doneButton: MDCButton!
    @IBOutlet weak var divider: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    lazy var viewModel = DatePickerViewModel()
    typealias DatePickerCallBack = (_ selectedDate: Date?) -> Void
    var callBack: DatePickerCallBack?
    private let bottomSheetTransition = DatePickerBottomSheetTransition()

    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isHidden = true
        datePicker.setContentHuggingPriority(.required, for: .vertical)
        datePicker.setContentCompressionResistancePriority(.required, for: .vertical)
        // Inside the safe area the calendar's margins can't feed back into its height; rotation hung otherwise.
        baseView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        applyLocalization()
        applyComponentsThemes()
        addAccessibility()
    }
    
    func addAccessibility() {
        cancelButton.accessibilityLabel = LocalizationConstants.Accessibility.closeButton
        cancelButton.accessibilityIdentifier = "cancel"
        
        doneButton.accessibilityLabel = LocalizationConstants.General.done
        doneButton.accessibilityIdentifier = "done"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        view.isHidden = false
    }
    
    // On iOS 26+ the inline calendar never settles inside the self-sizing MDC bottom sheet (ADST-923).
    func presentAsBottomSheet(from presenter: UIViewController?, completion: (() -> Void)? = nil) {
        modalPresentationStyle = .custom
        transitioningDelegate = bottomSheetTransition
        presenter?.present(self, animated: true, completion: completion)
    }

    override func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true, completion: nil)
        return true
    }

    override func willTransition(to newCollection: UITraitCollection,
                                 with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
    }
    
    // MARK: - Apply Themes and Localization
    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let buttonScheme = coordinatorServices?.themingService?.containerScheming(for: .toolBarButton) else { return }
        
        view.backgroundColor = currentTheme.surfaceColor
        divider.backgroundColor = currentTheme.onSurface12Color
        cancelButton.applyTextTheme(withScheme: buttonScheme)
        cancelButton.isUppercaseTitle = false
        doneButton.applyTextTheme(withScheme: buttonScheme)
        doneButton.isUppercaseTitle = false
        showDatePicker()
    }
    
    private func applyLocalization() {
        cancelButton.setTitle(LocalizationConstants.General.cancel, for: .normal)
        doneButton.setTitle(LocalizationConstants.General.done, for: .normal)
    }
    
    // MARK: - Button Actions
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        self.callBack?(datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Date Picker
extension DatePickerViewController {
    func showDatePicker() {
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme else { return }
        datePicker.backgroundColor = currentTheme.surfaceColor
        datePicker.date = viewModel.selectedDate ?? Date()
    }
}

// MARK: - Storyboard Instantiable
extension DatePickerViewController: SearchComponentsStoryboardInstantiable { }

// MARK: - Bottom Sheet Presentation
final class DatePickerBottomSheetTransition: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return DatePickerBottomSheetPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

final class DatePickerBottomSheetPresentationController: UIPresentationController {
    private let dimmingView = UIView()

    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView,
              let content = (presentedViewController as? DatePickerViewController)?.baseView else { return .zero }
        let width = containerView.bounds.width
        let insets = containerView.safeAreaInsets
        let fittingSize = CGSize(width: width - insets.left - insets.right,
                                 height: UIView.layoutFittingCompressedSize.height)
        let contentHeight = content.systemLayoutSizeFitting(fittingSize,
                                                            withHorizontalFittingPriority: .required,
                                                            verticalFittingPriority: .fittingSizeLevel).height
        let height = min(ceil(contentHeight) + insets.bottom, containerView.bounds.height)
        return CGRect(x: 0, y: containerView.bounds.height - height, width: width, height: height)
    }

    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.frame = containerView.bounds
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.alpha = 0
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped)))
        containerView.insertSubview(dimmingView, at: 0)
        presentedView?.accessibilityViewIsModal = true
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 1
        })
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.dimmingView.alpha = 0
        })
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        let frame = frameOfPresentedViewInContainerView
        if presentedView?.frame != frame {
            presentedView?.frame = frame
        }
    }

    @objc private func dimmingViewTapped() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
