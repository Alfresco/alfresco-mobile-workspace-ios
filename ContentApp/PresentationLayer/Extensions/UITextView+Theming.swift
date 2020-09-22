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

extension UITextView {
    func add(characterSpacing kernValue: Double, lineHeight: CGFloat) {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            let style = NSMutableParagraphStyle()
            let range = NSRange(location: 0, length: labelText.count)

            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: range)

            style.lineSpacing = lineHeight
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)

            attributedText = attributedString
        }
    }

    func applyStyleBody2OnSurface(theme: PresentationTheme) {
        self.add(characterSpacing: theme.body2TextStyle.letterSpacing, lineHeight: theme.body2TextStyle.lineHeight)
        self.textColor = theme.onSurfaceColor
        self.font = theme.body2TextStyle.font
    }
}
