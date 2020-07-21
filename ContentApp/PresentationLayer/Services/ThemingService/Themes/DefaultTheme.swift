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
    var primaryVariantColor = #colorLiteral(red: 0, green: 0.3215686275, blue: 0.6823529412, alpha: 1)
    var primaryColor = #colorLiteral(red: 0.1647058824, green: 0.4901960784, blue: 0.8823529412, alpha: 1)
    var primaryOnColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var surfaceColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var surfaceOnColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)
    var backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var backgroundOnColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var errorColor = #colorLiteral(red: 0.6901960784, green: 0, blue: 0.1254901961, alpha: 1)
    var errorOnColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var dividerColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.15)

    // MARK: - TYPOGRAPHY
    /// Buttons
    var signOutButtonFont = UIFont.alfrescoRegularFont(ofSize: 14)
    /// Labels
    var settingsTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var settingsSubtitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var listNodeCellTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var listNodeCellSubtitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var emptyListTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 28)
    var emptyListSubtitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var recentSearchesTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 14)
    var recentSearcheTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var searchChipTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)

    // MARK: - COLORS
    /// Buttons
    var signOutButtonColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    var signOutTextButtonColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)
    /// Labels
    var settingsTitleLabelColor = #colorLiteral(red: 0.1279757321, green: 0.1371012032, blue: 0.158791095, alpha: 1)
    var settingsSubtitleLabelColor = #colorLiteral(red: 0.5284697413, green: 0.5335359573, blue: 0.5419467092, alpha: 1)
    var listNodeCellTitleLabelColor = #colorLiteral(red: 0.09803921569, green: 0.1019607843, blue: 0.1176470588, alpha: 1)
    var listNodeCellSubtitleLabelColor = #colorLiteral(red: 0.4549019608, green: 0.4588235294, blue: 0.4666666667, alpha: 1)
    var emptyListTitleLabelColor = #colorLiteral(red: 0.1279757321, green: 0.1371012032, blue: 0.158791095, alpha: 1)
    var emptyListSubtitleLabelColor = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3294117647, alpha: 1)
    var recentSearchesTitleLabelColor = #colorLiteral(red: 0.3254901961, green: 0.3254901961, blue: 0.3254901961, alpha: 1)
    var recentSearcheTitleLabelColor = #colorLiteral(red: 0.09803921569, green: 0.1019607843, blue: 0.1176470588, alpha: 1)
    /// Views
//    var backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var snackbarErrorColor = #colorLiteral(red: 0.8117647059, green: 0, blue: 0.1607843137, alpha: 1)
    var snackbarApproved = #colorLiteral(red: 0.1921568627, green: 0.5490196078, blue: 0.1725490196, alpha: 1)
    var snackbarWarning = #colorLiteral(red: 0.9333333333, green: 0.6078431373, blue: 0.1843137255, alpha: 1)
    var settingsIconColor = #colorLiteral(red: 0.3254901961, green: 0.3254901961, blue: 0.3254901961, alpha: 1)
    var searchChipSelectedColor = #colorLiteral(red: 0.1333333333, green: 0.3960784314, blue: 0.8549019608, alpha: 1)
    var searchChipUnselectedColor = #colorLiteral(red: 0.3254901961, green: 0.3254901961, blue: 0.3254901961, alpha: 1)
    var tabBarBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var tabBarUnselectedItemTinColor = #colorLiteral(red: 0.4, green: 0.4, blue: 0.4, alpha: 1)
    var tabBarSelectedItemTintColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)
    var listNodeCellIconColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
}
