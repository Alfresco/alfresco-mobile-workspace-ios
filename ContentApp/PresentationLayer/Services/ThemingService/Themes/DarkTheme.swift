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
    var headline3Font = UIFont.alfrescoRegularFont(ofSize: 48)
    var headline4Font = UIFont.alfrescoRegularFont(ofSize: 34)
    var headline5Font = UIFont.alfrescoRegularFont(ofSize: 24)
    var headline6Font = UIFont.alfrescoRegularFont(ofSize: 20)
    var subtitle1Font = UIFont.alfrescoRegularFont(ofSize: 16)
    var subtitle2Font = UIFont.alfrescoRegularFont(ofSize: 14)
    var buttonFont = UIFont.alfrescoRegularFont(ofSize: 14)
    var body1Font = UIFont.alfrescoRegularFont(ofSize: 16)
    var body2Font = UIFont.alfrescoRegularFont(ofSize: 14)
    var captionFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var overlineFont = UIFont.alfrescoRegularFont(ofSize: 10)

    // COLORS
    var primaryVariantColor = #colorLiteral(red: 0.431372549, green: 0.6745098039, blue: 1, alpha: 1)
    var primaryColor = #colorLiteral(red: 0.1647058824, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    var primaryOnColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var surfaceColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
    var surfaceOnColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
    var backgroundOnColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var errorColor = #colorLiteral(red: 0.8117647059, green: 0.4, blue: 0.4745098039, alpha: 1)
    var errorOnColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var dividerColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.15)
}
