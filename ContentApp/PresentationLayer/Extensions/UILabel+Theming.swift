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
    func applyStyleCaptionOnSurface60(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor.withAlphaComponent(0.6)
        self.font = theme.captionFont
    }

    func applyStyleSubtitle1OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.subtitle1Font
    }

    func applyStyleBody1OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.body1Font
    }

    func applyStyleSubtitle2OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.subtitle2Font
    }

    func applyStyleSubtitle2OnSurface60(theme: PresentationTheme) {
        self.font = theme.subtitle2Font
        self.textColor = theme.onSurfaceColor.withAlphaComponent(0.6)
    }

    func applyStyleSubtitle1Divider(theme: PresentationTheme) {
        self.textColor = theme.dividerColor
        self.font = theme.subtitle1Font
    }

    func applyeStyleHeadline5OnSurface(theme: PresentationTheme) {
        self.textColor = theme.onSurfaceColor
        self.font = theme.headline5Font
    }
}
