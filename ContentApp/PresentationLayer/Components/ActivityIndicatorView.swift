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

enum ActivityIndicatorControllerType {
    case login
    case search
}

class ActivityIndicatorView: UIView {
    private var activityIndicator = MDCActivityIndicator()
    private var overlayView: UIView?
    private var label: UILabel = UILabel()
    private var type: ActivityIndicatorControllerType

    var state: ActivityIndicatorControllerState? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let sSelf = self else { return }
                let window = UIApplication.shared.windows[0]
                window.isUserInteractionEnabled = (sSelf.state == .isIdle)
                (sSelf.state == .isIdle) ? sSelf.removeFromSuperview() : window.addSubview(sSelf)
            }
        }
    }

    // MARK: - Init

    init(themingService: MaterialDesignThemingService?, type: ActivityIndicatorControllerType = .login) {
        self.type = type
        super.init(frame: UIApplication.shared.windows[0].bounds)
        self.commonInit()
        self.applyTheme(themingService)
    }

    required init?(coder: NSCoder) {
        self.type = .login
        super.init(coder: coder)
        self.commonInit()
    }

    // MARK: - Public Helpers

    func label(text: String) {
        label.text = text
    }

    func reload(from size: CGSize) {
        self.frame.size = size
        overlayView?.frame.size = size
        activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y - self.frame.height / 7)
    }

    // MARK: - Private Helpers

    private func applyTheme(_ themingService: MaterialDesignThemingService?) {
        activityIndicator.cycleColors = [themingService?.activeTheme?.activityIndicatorViewColor ?? .black]
        label.textColor = themingService?.activeTheme?.activityIndicatorLabelColor
        label.font = themingService?.activeTheme?.activityIndicatorLabelFont

        switch self.type {
        case .search:
            label.text = LocalizationConstants.Search.searching
            activityIndicator.cycleColors = [themingService?.activeTheme?.activityIndicatorSearchViewColor ?? .black]
        default:
            label.text = LocalizationConstants.Labels.conneting
            activityIndicator.cycleColors = [themingService?.activeTheme?.activityIndicatorViewColor ?? .black]
        }
    }

    private func commonInit() {
        self.isUserInteractionEnabled = false

        overlayView = UIView(frame: frame)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        switch self.type {
        case .search:
            activityIndicator.radius = 12
            activityIndicator.strokeWidth = 2
        default:
            activityIndicator.radius = 40
            activityIndicator.strokeWidth = 7
        }
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y - self.frame.height / 7)
        
        if let overlayView = self.overlayView {
            if #available(iOS 13.0, *) {
                overlayView.backgroundColor = .systemBackground
            } else {
                overlayView.backgroundColor = .white
            }
            overlayView.alpha = 0.87
            self.addSubview(overlayView)
            self.addSubview(activityIndicator)
            self.addSubview(label)
            activityIndicator.startAnimating()
            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 250),
                label.heightAnchor.constraint(equalToConstant: 20),
                label.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 56.0)
            ])
        }
    }
}
