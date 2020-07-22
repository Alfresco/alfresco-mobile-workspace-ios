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
    // TYPOGRAPHY
    var headline3Font: UIFont { get }
    var headline4Font: UIFont { get }
    var headline5Font: UIFont { get }
    var headline6Font: UIFont { get }
    var subtitle1Font: UIFont { get }
    var subtitle2Font: UIFont { get }
    var buttonFont: UIFont { get }
    var body1Font: UIFont { get }
    var body2Font: UIFont { get }
    var captionFont: UIFont { get }
    var overlineFont: UIFont { get }

    // COLORS
    var primaryVariantColor: UIColor { get }
    var primaryColor: UIColor { get }
    var primaryOnColor: UIColor { get }
    var surfaceColor: UIColor { get }
    var onSurfaceColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var onBackgroundColor: UIColor { get }
    var errorColor: UIColor { get }
    var errorOnColor: UIColor { get }
    var dividerColor: UIColor { get }
}
