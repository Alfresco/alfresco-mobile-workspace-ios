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

protocol NeedHelpModelProtocol {
    var titleText: String { get }
    var hintText: String { get }
}

class NeedHelpViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!

    var model: NeedHelpModelProtocol?
    var themingService: ThemingService?

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = model?.titleText
        if let needHelpTextViewFont = themingService?.activeTheme?.needHelpHintTextViewFont,
            let titleLabelFont = themingService?.activeTheme?.needHelpTitleLabelFont {
            textView.attributedText = NSAttributedString(withLocalizedHTMLString: model?.hintText ?? "",
                                                         font: needHelpTextViewFont)
            titleLabel.font = titleLabelFont
        }

        if let needHelpTextViewColor = themingService?.activeTheme?.needHelpHintTextViewColor,
            let titleLabelColor = themingService?.activeTheme?.needHelpTitleColor {
            titleLabel.textColor = titleLabelColor
            textView.textColor = needHelpTextViewColor
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        textView.contentInset = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        textView.contentOffset = .zero
        textViewHeightConstraint.constant = textView.calculatedContentSize().height
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calculatePreferredSize()
    }

    private func calculatePreferredSize() {
        let targetSize = CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height)
        preferredContentSize = view.systemLayoutSizeFitting(targetSize)
    }

    // MARK: - Actions

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension NeedHelpViewController: StoryboardInstantiable { }
