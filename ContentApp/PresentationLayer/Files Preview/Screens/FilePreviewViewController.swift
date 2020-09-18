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
import MaterialComponents.MaterialProgressView

class FilePreviewViewController: SystemThemableViewController {
    @IBOutlet weak var containerFilePreview: UIView!
    @IBOutlet weak var progressView: MDCProgressView!

    @IBOutlet var previewContraintsToSafeArea: [NSLayoutConstraint]!
    @IBOutlet var previewContraintsToSuperview: [NSLayoutConstraint]!

    var filePreviewViewModel: FilePreviewViewModel?
    var isFullScreen = false
    var needsContraintsForFullScreen = false
    var filePreview: FilePreviewProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)

        startLoading()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChangedNotification),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        appDelegate?.allowedOrientation = .all
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filePreviewViewModel?.requestFilePreview(with: containerFilePreview.bounds.size)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Remove navigation bar underline separator
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()

        tabBarController?.tabBar.isHidden = false

        appDelegate?.allowedOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")

        filePreview?.cancel()
        filePreview?.removeFromSuperview()

        Snackbar.dimissAll()
    }

    override var prefersStatusBarHidden: Bool {
        return isFullScreen
    }

    // MARK: - Private Helpers

    private func activateContraintsToSuperview() {
        NSLayoutConstraint.deactivate(previewContraintsToSafeArea)
        NSLayoutConstraint.activate(previewContraintsToSuperview)
        view.layoutIfNeeded()
        containerFilePreview.layoutIfNeeded()
    }

    private func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: false)
    }

    private func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
    }

    @objc private func orientationChangedNotification() {
        if needsContraintsForFullScreen {
            activateContraintsToSuperview()
        }
        filePreview?.recalculateFrame(from: containerFilePreview.bounds.size)
    }

    override func applyComponentsThemes() {
        guard let themingService = self.themingService, let currentTheme = themingService.activeTheme else { return }
        view.backgroundColor = currentTheme.backgroundColor
        filePreview?.applyComponentsThemes(themingService.activeTheme)

        navigationController?.navigationBar.backgroundColor = currentTheme.backgroundColor
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension FilePreviewViewController: FilePreviewViewModelDelegate {

    func display(view: FilePreviewProtocol) {
        containerFilePreview.addSubview(view)
        filePreview = view
        filePreview?.delegate = self
        filePreview?.applyComponentsThemes(themingService?.activeTheme)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: containerFilePreview.topAnchor, constant: 0),
            view.leftAnchor.constraint(equalTo: containerFilePreview.leftAnchor, constant: 0),
            view.rightAnchor.constraint(equalTo: containerFilePreview.rightAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: containerFilePreview.bottomAnchor, constant: 0)
        ])
    }

    func display(doneRequesting: Bool, error: Error?) {
        if doneRequesting {
            stopLoading()
        }
    }

    func calculateViewForFullscreen() {
        needsContraintsForFullScreen = true
        activateContraintsToSuperview()
    }
}

// MARK: - FilePreview Delegate

extension FilePreviewViewController: FilePreviewDelegate {
    func applyFullScreen(_ enable: Bool) {
        isFullScreen = enable
        containerFilePreview.backgroundColor = (isFullScreen) ? .black : .clear
        navigationController?.setNavigationBarHidden(isFullScreen, animated: true)
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Storyboard Instantiable

extension FilePreviewViewController: StoryboardInstantiable { }
