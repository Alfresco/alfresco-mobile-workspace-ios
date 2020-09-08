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
    var filePreviewViewModel: PreviewFileViewModel?

    var subViewPreview: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        progressView.progress = 0
        progressView.mode = .indeterminate
        view.bringSubviewToFront(progressView)

        startLoading()
        filePreviewViewModel?.requestFilePreview(with: preview.bounds.size)

        appDelegate?.restrictRotation = .all

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChangedNotification),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false

        appDelegate?.restrictRotation = .portrait
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
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
        subViewPreview?.frame = CGRect(origin: .zero, size: preview.bounds.size)
    }

    override func applyComponentsThemes() {
        guard let currentTheme = self.themingService?.activeTheme else { return }
        view.backgroundColor = currentTheme.backgroundColor
    }
}

// MARK: - PreviewFile ViewModel Delegate

extension FilePreviewViewController: PreviewFileViewModelDelegate {

    func display(view: UIView) {
        stopLoading()
        preview.addSubview(view)
        subViewPreview = view
    }

    func display(error: Error) {
        stopLoading()
    }
}

// MARK: - Storyboard Instantiable

extension FilePreviewViewController: StoryboardInstantiable { }
