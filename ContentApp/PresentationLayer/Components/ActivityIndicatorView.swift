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

struct ActivityIndicatorConfiguration {
    var title: String
    var radius: CGFloat
    var strokeWidth: CGFloat
    var cycleColors: [UIColor]

    init(title: String, radius: CGFloat, strokeWidth: CGFloat, cycleColors: [UIColor]) {
        self.title = title
        self.radius = radius
        self.strokeWidth = strokeWidth
        self.cycleColors = cycleColors
    }

    static var defaultValue = ActivityIndicatorConfiguration(title: LocalizationConstants.Labels.conneting,
                                                             radius: 40,
                                                             strokeWidth: 7,
                                                             cycleColors: [.black])
}

class ActivityIndicatorView: UIView {
    private var activityIndicator = MDCActivityIndicator()
    private var overlayView: UIView?
    private var label: UILabel = UILabel()
    private var activityIndicatorConfiguration: ActivityIndicatorConfiguration

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

    init(currentTheme: PresentationTheme?, configuration: ActivityIndicatorConfiguration) {
        self.activityIndicatorConfiguration = configuration
        super.init(frame: kWindow.bounds)
        self.commonInit()
        self.applyTheme(currentTheme)
    }

    required init?(coder: NSCoder) {
        self.activityIndicatorConfiguration = ActivityIndicatorConfiguration.defaultValue
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

    private func applyTheme(_ currentTheme: PresentationTheme?) {
        activityIndicator.cycleColors = activityIndicatorConfiguration.cycleColors
        label.textColor = currentTheme?.dividerColor
        label.font = currentTheme?.subtitle1Font
        label.text = activityIndicatorConfiguration.title
    }

    private func commonInit() {
        self.isUserInteractionEnabled = false

        overlayView = UIView(frame: frame)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        activityIndicator.radius = activityIndicatorConfiguration.radius
        activityIndicator.strokeWidth = activityIndicatorConfiguration.strokeWidth
        activityIndicator.sizeToFit()
        activityIndicator.center = CGPoint(x: self.center.x, y: self.center.y - self.frame.height / 7)

        if let overlayView = self.overlayView {
            overlayView.backgroundColor = superview?.backgroundColor
            overlayView.alpha = 0.87
            self.addSubview(overlayView)
            self.addSubview(activityIndicator)
            self.addSubview(label)

            NSLayoutConstraint.activate([
                label.widthAnchor.constraint(equalToConstant: 250),
                label.heightAnchor.constraint(equalToConstant: 20),
                label.centerXAnchor.constraint(equalTo: activityIndicator.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 56.0)
            ])
        }
        self.state = .isIdle
    }
}
