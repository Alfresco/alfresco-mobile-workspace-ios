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

struct DefaultTheme: PresentationTheme {

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

    var surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var onSurfaceColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)
    var onSurface60Color = #colorLiteral(red: 0.4784313725, green: 0.4823529412, blue: 0.4941176471, alpha: 1)
    var onSurface30Color = #colorLiteral(red: 0.737254902, green: 0.7411764706, blue: 0.7490196078, alpha: 1)
    var onSurface15Color = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8745098039, alpha: 1)
    var onSurface5Color = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
    var backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    var onBackgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var errorColor = #colorLiteral(red: 0.6901960784, green: 0, blue: 0.1254901961, alpha: 1)
    var errorOnColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var onPrimaryColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var onPrimaryInvertedColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)

    var primaryVariantT1Color = #colorLiteral(red: 0, green: 0.3215686275, blue: 0.6823529412, alpha: 1)
    var primaryColorVariant = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    var primaryT1Color = #colorLiteral(red: 0.1647058824, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    var primary30T1Color = #colorLiteral(red: 0.1647058824, green: 0.4901960784, blue: 0.8823529412, alpha: 0.3)
    var primary15T1Color = #colorLiteral(red: 0.1647058824, green: 0.4901960784, blue: 0.8823529412, alpha: 0.15)

    var primaryVariantT2Color = #colorLiteral(red: 1, green: 0.9098039216, blue: 0, alpha: 1)
    var primaryT2Color = #colorLiteral(red: 1, green: 0.7764705882, blue: 0, alpha: 1)

    var dividerColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8745098039, alpha: 1)
}
