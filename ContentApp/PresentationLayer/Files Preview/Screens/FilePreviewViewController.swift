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
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var progressView: MDCProgressView!

    var filePreviewViewModel: FilePreviewViewModel?
    var fullScreen = false
    var filePreview: FilePreviewProtocol? {
        didSet {
            appDelegate?.allowedOrientation = .all
        }
    }

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filePreviewViewModel?.requestFilePreview(with: preview.bounds.size)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false

        appDelegate?.allowedOrientation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        filePreview?.cancel()
        filePreview?.removeFromSuperview()
    }

    override var prefersStatusBarHidden: Bool {
        return fullScreen
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Private Helpers

    private func startLoading() {
        progressView.startAnimating()
        progressView.setHidden(false, animated: false)
    }

    private func stopLoading() {
        progressView.stopAnimating()
        progressView.setHidden(true, animated: false)
    }

    @objc private func orientationChangedNotification() {
        filePreview?.recalculateFrame(from: preview.bounds.size)
    }

    override func applyComponentsThemes() {
        guard let themingService = self.themingService, let currentTheme = themingService.activeTheme else { return }
        view.backgroundColor = currentTheme.backgroundColor
        filePreview?.applyComponentsThemes(themingService: themingService)
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension FilePreviewViewController: FilePreviewViewModelDelegate {

    func display(view: FilePreviewProtocol) {
        guard let themingService = self.themingService else { return }
        preview.addSubview(view)
        filePreview = view
        filePreview?.delegate = self
        filePreview?.applyComponentsThemes(themingService: themingService)

        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: self.preview.topAnchor, constant: 0),
            view.leftAnchor.constraint(equalTo: self.preview.leftAnchor, constant: 0),
            view.rightAnchor.constraint(equalTo: self.preview.rightAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: self.preview.bottomAnchor, constant: 0)
        ])
    }

    func display(doneRequesting: Bool, error: Error?) {
        if doneRequesting {
            stopLoading()
        }
    }
}

// MARK: - FilePreview Delegate

extension FilePreviewViewController: FilePreviewDelegate {
    func applyFullScreen(_ enable: Bool) {
//        navigationController?.setNavigationBarHidden(enable, animated: true)
//        fullScreen = enable
//        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Storyboard Instantiable

extension FilePreviewViewController: StoryboardInstantiable { }
