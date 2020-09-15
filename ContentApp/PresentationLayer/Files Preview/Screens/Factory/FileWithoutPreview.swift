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
    weak var delegate: FilePreviewDelegate?
    private var noPreviewLabel: UILabel?

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = LocalizationConstants.FilePreview.noPreview
        label.sizeToFit()
        noPreviewLabel = label

        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - FilePreviewProtocol

    func applyComponentsThemes(themingService: MaterialDesignThemingService) {
        guard let currentTheme = themingService.activeTheme else { return }
        noPreviewLabel?.applyStyleBody2OnSurface(theme: currentTheme)
    }

    func recalculateFrame(from size: CGSize) {
        frame = CGRect(origin: .zero, size: size)
        noPreviewLabel?.center = center
    }

    func cancel() {
    }
}
