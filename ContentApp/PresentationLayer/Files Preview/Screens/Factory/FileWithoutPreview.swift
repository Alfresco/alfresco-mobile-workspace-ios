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

import Foundation
import UIKit

class FileWithoutPreview: UIView, FilePreviewProtocol {
    private var statusLabel: UILabel?
    private var titleLabel: UILabel?
    private var iconImageView: UIImageView?

    // MARK: - Init

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(with node: ListNode?) {
        super.init(frame: CGRect(origin: .zero, size: .zero))
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        let imageView = UIImageView(image: FileIcon.icon(for: node))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView = imageView
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            imageView.widthAnchor.constraint(equalToConstant: 72),
            imageView.heightAnchor.constraint(equalToConstant: 72)
        ])

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byTruncatingTail
        titleLabel.text = node?.title
        titleLabel.sizeToFit()
        self.titleLabel = titleLabel
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 77),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -77)
        ])

        let statuslabel = UILabel()
        statuslabel.translatesAutoresizingMaskIntoConstraints = false
        statuslabel.textAlignment = .center
        statuslabel.text = LocalizationConstants.FilePreview.noPreview
        statuslabel.sizeToFit()
        self.statusLabel = statuslabel
        addSubview(statuslabel)
        NSLayoutConstraint.activate([
            statuslabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            statuslabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4)
        ])
        
        imageView.accessibilityIdentifier = "filePreviewNodeMimeTypeImageView"
        imageView.isAccessibilityElement = true
        titleLabel.accessibilityIdentifier = "filePreviewNodeTitleLabel"
        statuslabel.accessibilityIdentifier = "filePreviewNodeStatusLabel"
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        statusLabel?.applyStyleCaptionOnSurface60(theme: currentTheme)
        titleLabel?.font = currentTheme.body2TextStyle.font
        titleLabel?.textColor = currentTheme.onSurfaceColor
    }
}
