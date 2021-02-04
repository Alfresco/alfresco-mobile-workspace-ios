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
import MaterialComponents.MaterialActivityIndicator

enum ActivityIndicatorControllerState {
    case isLoading
    case isIdle
}

class ActivityIndicatorView: UIView {
    private var activityIndicator = MDCActivityIndicator()
    private var overlayView: UIView?
    private var label: UILabel = UILabel()

    var state: ActivityIndicatorControllerState? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                (sSelf.state == .isLoading) ? sSelf.activityIndicator.startAnimating() : sSelf.activityIndicator.stopAnimating()
                sSelf.isHidden = (sSelf.state == .isIdle)
                sSelf.superview?.isUserInteractionEnabled = (sSelf.state == .isIdle)
            }
        }
    }

    // MARK: - Init

    init(currentTheme: PresentationTheme?) {
        super.init(frame: UIApplication.shared.windows[0].bounds)
        self.commonInit()
        self.applyTheme(currentTheme)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.commonInit()
    }

    // MARK: - Public Helpers

    func label(text: String) {
        label.text = text
    }

    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        activityIndicator.cycleColors = [currentTheme.primaryVariantT1Color]
        label.applyStyleBody2OnSurface60(theme: currentTheme)
        label.textAlignment = .center
        overlayView?.backgroundColor = currentTheme.surfaceColor
    }

    func recalculateSize(_ size: CGSize) {
        frame.size = size
        overlayView?.frame = frame
    }

    // MARK: - Private Helpers

    private func commonInit() {
        self.isUserInteractionEnabled = false

        overlayView = UIView(frame: frame)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.radius = 12.0
        activityIndicator.strokeWidth = 2.0
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.sizeToFit()

        if let overlayView = self.overlayView {
            overlayView.backgroundColor = .white
            self.addSubview(overlayView)
            self.addSubview(activityIndicator)
            self.addSubview(label)

            NSLayoutConstraint.activate([
                activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -self.frame.size.height / 6),
                activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
                label.widthAnchor.constraint(equalToConstant: 250),
                label.heightAnchor.constraint(equalToConstant: 20),
                label.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 40.0)
            ])
        }
        self.state = .isIdle
    }
}
