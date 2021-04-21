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
typealias TextStyle = (font: UIFont, lineHeight: CGFloat, letterSpacing: Double)

protocol PresentationTheme {
    // TYPOGRAPHY
    var headline3TextStyle: TextStyle { get }
    var headline4TextStyle: TextStyle { get }
    var headline5TextStyle: TextStyle { get }
    var headline6TextStyle: TextStyle { get }
    var subtitle1TextStyle: TextStyle { get }
    var subtitle2TextStyle: TextStyle { get }
    var buttonTextStyle: TextStyle { get }
    var body1TextStyle: TextStyle { get }
    var body2TextStyle: TextStyle { get }
    var captionTextStyle: TextStyle { get }
    var overlineTextStyle: TextStyle { get }

    // COLORS

    var surfaceColor: UIColor { get }
    var surface60Color: UIColor { get }
    var onSurfaceColor: UIColor { get }
    var onSurface60Color: UIColor { get }
    var onSurface30Color: UIColor { get }
    var onSurface15Color: UIColor { get }
    var onSurface5Color: UIColor { get }
    var backgroundColor: UIColor { get }
    var onBackgroundColor: UIColor { get }
    var errorColor: UIColor { get }
    var errorOnColor: UIColor { get }
    var onPrimaryColor: UIColor { get }
    var onPrimaryInvertedColor: UIColor { get }

    var primaryVariantT1Color: UIColor { get }
    var primaryColorVariant: UIColor { get }
    var primaryT1Color: UIColor { get }
    var primary30T1Color: UIColor { get }
    var primary15T1Color: UIColor { get }

    var dividerColor: UIColor { get }
    var videoShutterColor: UIColor { get }
}
