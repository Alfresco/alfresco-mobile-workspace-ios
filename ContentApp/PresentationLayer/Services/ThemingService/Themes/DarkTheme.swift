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

struct DarkTheme: PresentationTheme {
    // TYPOGRAPHY
   var headline3TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 48.0), lineHeight: 1.33, letterSpacing: 0.0)
    var headline4TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 34.0), lineHeight: 1.41, letterSpacing: 0.25)
    var headline5TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 24.0), lineHeight: 1.50, letterSpacing: 0.0)
    var headline6TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 20.0), lineHeight: 1.40, letterSpacing: 0.15)
    var subtitle1TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 16.0), lineHeight: 1.50, letterSpacing: 0.15)
    var subtitle2TextStyle = TextStyle(font: UIFont.inter(style: .medium, size: 14.0), lineHeight: 1.43, letterSpacing: 0.1)
    var buttonTextStyle = TextStyle(font: UIFont.inter(style: .medium, size: 14.0), lineHeight: 1.71, letterSpacing: 0.1)
    var body1TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 16.0), lineHeight: 1.50, letterSpacing: 0.444444)
    var body2TextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 14.0), lineHeight: 1.43, letterSpacing: 0.25)
    var captionTextStyle = TextStyle(font: UIFont.inter(style: .normal, size: 12.0), lineHeight: 1.33, letterSpacing: 0.5)
    var overlineTextStyle = TextStyle(font: UIFont.inter(style: .medium, size: 10.0), lineHeight: 1.60, letterSpacing: 0.2)

    // COLORS
    var primaryVariantColor = #colorLiteral(red: 0.431372549, green: 0.6745098039, blue: 1, alpha: 1)
    var primaryColor = #colorLiteral(red: 0.1647058824, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    var onPrimaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var surfaceColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
    var onSurfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
    var onBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var errorColor = #colorLiteral(red: 0.8117647059, green: 0.4, blue: 0.4745098039, alpha: 1)
    var errorOnColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var dividerColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.15)
}
