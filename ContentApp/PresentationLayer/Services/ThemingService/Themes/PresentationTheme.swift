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
    var surfaceOnColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var backgroundOnColor: UIColor { get }
    var errorColor: UIColor { get }
    var errorOnColor: UIColor { get }
    var dividerColor: UIColor { get }

    // TYPOGRAPHY -
    /// Buttons
    var signOutButtonFont: UIFont { get }
    /// Labels
    var settingsTitleLabelFont: UIFont { get }
    var settingsSubtitleLabelFont: UIFont { get }
    var listNodeCellTitleLabelFont: UIFont { get }
    var listNodeCellSubtitleLabelFont: UIFont { get }
    var emptyListTitleLabelFont: UIFont { get }
    var emptyListSubtitleLabelFont: UIFont { get }
    var recentSearchesTitleLabelFont: UIFont { get }
    var recentSearcheTitleLabelFont: UIFont { get }
    var searchChipTitleLabelFont: UIFont { get }
    var listNodeSectionTitleLabelFont: UIFont { get }

    // COLORS
    /// Buttons
    var signOutButtonColor: UIColor { get }
    var signOutTextButtonColor: UIColor { get }
    /// Labels
    var settingsTitleLabelColor: UIColor { get }
    var settingsSubtitleLabelColor: UIColor { get }
    var listNodeCellTitleLabelColor: UIColor { get }
    var listNodeCellSubtitleLabelColor: UIColor { get }
    var emptyListTitleLabelColor: UIColor { get }
    var emptyListSubtitleLabelColor: UIColor { get }
    var recentSearchesTitleLabelColor: UIColor { get }
    var recentSearcheTitleLabelColor: UIColor { get }
    var listNodeSectionTitleLabelColor: UIColor { get }
    /// Views
//    var backgroundColor: UIColor { get }
    var snackbarErrorColor: UIColor { get }
    var snackbarApproved: UIColor { get }
    var snackbarWarning: UIColor { get }
    var settingsIconColor: UIColor { get }
    var searchChipSelectedColor: UIColor { get }
    var searchChipUnselectedColor: UIColor { get }
    var tabBarBackgroundColor: UIColor { get }
    var tabBarUnselectedItemTinColor: UIColor { get }
    var tabBarSelectedItemTintColor: UIColor { get }
    var listNodeCellIconColor: UIColor { get }
}
