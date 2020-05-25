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

protocol PresentationTheme {
    // TYPOGRAPHY - LOGIN COMPONENTS
    var applicationTitleFont: UIFont { get }
    var loginUrlTextFieldFont: UIFont { get }
    var loginButtonFont: UIFont { get }
    var loginUtilitiesButtonFont: UIFont { get }

    // COLORS - LOGIN COMPONENTS
    var applicationTitleColor: UIColor { get }
    var loginButtonColor: UIColor { get }
    var loginURLTextFieldPrimaryColor: UIColor { get }
    var loginURLTextFieldErrorColor: UIColor { get }
    var loginURLTextFieldOnSurfaceColor: UIColor { get }
    var loginNeedHelpButtonColor: UIColor { get }
    var loginAdvancedSettingsButtonColor: UIColor { get }
}

struct DefaultTheme: PresentationTheme {
    // MARK: - TYPOGRAPHY - LOGIN COMPONENTS
    var applicationTitleFont = UIFont.systemFont(ofSize: 24)
    var loginUrlTextFieldFont = UIFont.systemFont(ofSize: 16)
    var loginButtonFont = UIFont.systemFont(ofSize: 24)
    var loginUtilitiesButtonFont = UIFont.systemFont(ofSize: 14)

    // MARK: - COLORS - LOGIN COMPONENTS
    var applicationTitleColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    var loginButtonColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
    var loginURLTextFieldPrimaryColor = #colorLiteral(red: 0.2474783659, green: 0.6575964093, blue: 0.2639612854, alpha: 1)
    var loginURLTextFieldErrorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
    var loginURLTextFieldOnSurfaceColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)
    var loginNeedHelpButtonColor = #colorLiteral(red: 0, green: 0.3333333333, blue: 0.7215686275, alpha: 1)
    var loginAdvancedSettingsButtonColor = #colorLiteral(red: 0.1219744459, green: 0.459923327, blue: 0.2891728282, alpha: 1)
}
