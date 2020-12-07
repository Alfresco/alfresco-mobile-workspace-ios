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

class NeedHelpViewController: SystemThemableViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    var model: NeedHelpModelProtocol?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.applyRoundedCorners(on: [.topLeft, .topRight], radius: dialogCornerRadius)
        view.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textView.contentInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        textView.contentOffset = .zero
        textViewHeightConstraint.constant = textView.calculatedContentSize().height
        view.isHidden = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize(view.bounds.size)
    }

    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        calculatePreferredSize(size)
    }

    // MARK: - Private Utils

    private func calculatePreferredSize(_ size: CGSize) {
        let targetSize = CGSize(width: size.width, height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }

    override func applyComponentsThemes() {
        super.applyComponentsThemes()
        guard let currentTheme = coordinatorServices?.themingService?.activeTheme,
              let model = model else { return }

        textView.text = model.allText()
        let mAtrString = NSMutableAttributedString(string: textView.text)

        for section in model.sections {
            mAtrString.addAttributes([.foregroundColor: currentTheme.onSurfaceColor,
                                      .font: currentTheme.subtitle1TextStyle.font],
                                     range: (model.allText() as NSString).range(of: section.title))
            mAtrString.addAttributes([.foregroundColor: currentTheme.onSurface60Color,
                                      .font: currentTheme.body2TextStyle.font],
                                     range: (model.allText() as NSString).range(of: section.paragraphs))
        }
        textView.attributedText = mAtrString

        titleLabel.text = model.title
        titleLabel.applyeStyleHeadline6OnSurface(theme: currentTheme)

        closeButton.tintColor = currentTheme.onSurface60Color
        view.backgroundColor = currentTheme.surfaceColor
    }

    // MARK: - Actions

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension NeedHelpViewController: StoryboardInstantiable { }
