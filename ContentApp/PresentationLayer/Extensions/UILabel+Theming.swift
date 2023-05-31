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

extension UILabel {
    func add(characterSpacing kernValue: Double, lineHeight: CGFloat) {
        if let labelText = text, !labelText.isEmpty {
            let attributedString = NSMutableAttributedString(string: labelText)
            let style = NSMutableParagraphStyle()
            let range = NSRange(location: 0, length: labelText.count)

            attributedString.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: range)

            style.lineSpacing = lineHeight
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)

            attributedText = attributedString
        }
    }

    func applyStyleCaptionOnSurface60(theme: PresentationTheme) {
        self.textColor = theme.onSurface60Color
        self.font = theme.captionTextStyle.font
        self.add(characterSpacing: theme.captionTextStyle.letterSpacing, lineHeight: theme.captionTextStyle.lineHeight)
    }

    func applyStyleSubtitle1OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.subtitle1TextStyle.font
        self.add(characterSpacing: theme.subtitle1TextStyle.letterSpacing, lineHeight: theme.subtitle1TextStyle.lineHeight)
    }

    func applyStyleBody1OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.body1TextStyle.font
        self.add(characterSpacing: theme.body1TextStyle.letterSpacing, lineHeight: theme.body1TextStyle.lineHeight)
    }

    func applyStyleBody2OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.body2TextStyle.font
        self.add(characterSpacing: theme.body2TextStyle.letterSpacing, lineHeight: theme.body2TextStyle.lineHeight)
    }

    func applyStyleBody2OnSurface60(theme: PresentationTheme) {
        self.textColor = theme.onSurface60Color
        self.font = theme.body2TextStyle.font
        self.add(characterSpacing: theme.body2TextStyle.letterSpacing, lineHeight: theme.body2TextStyle.lineHeight)
    }

    func applyStyleSubtitle2OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.subtitle2TextStyle.font
        self.add(characterSpacing: theme.subtitle2TextStyle.letterSpacing, lineHeight: theme.subtitle2TextStyle.lineHeight)
    }

    func applyStyleSubtitle2OnSurface60(theme: PresentationTheme) {
        self.textColor = theme.onSurface60Color
        self.font = theme.subtitle2TextStyle.font
        self.add(characterSpacing: theme.subtitle2TextStyle.letterSpacing, lineHeight: theme.subtitle2TextStyle.lineHeight)
    }

    func applyeStyleHeadline5OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.headline5TextStyle.font
        self.add(characterSpacing: theme.headline5TextStyle.letterSpacing, lineHeight: theme.headline5TextStyle.lineHeight)
    }

    func applyeStyleHeadline6OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.headline6TextStyle.font
        self.add(characterSpacing: theme.headline6TextStyle.letterSpacing, lineHeight: theme.headline6TextStyle.lineHeight)
    }

    func applyeStyleHeadline6OnSurface60(theme: PresentationTheme) {
        self.textColor = theme.onSurface60Color
        self.font = theme.headline6TextStyle.font
        self.add(characterSpacing: theme.headline6TextStyle.letterSpacing, lineHeight: theme.headline6TextStyle.lineHeight)
    }
    
    func applyStyleHeadLineBoldOnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.headLineBoldTextStyle.font
        self.add(characterSpacing: theme.headLineBoldTextStyle.letterSpacing, lineHeight: theme.headLineBoldTextStyle.lineHeight)
    }
    
    func applyStyleSubtitle2OnSurface30(theme: PresentationTheme) {
        self.textColor = theme.onSurface30Color
        self.font = theme.subtitle2TextStyle.font
        self.add(characterSpacing: theme.subtitle2TextStyle.letterSpacing, lineHeight: theme.subtitle2TextStyle.lineHeight)
    }
}
