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
    // MARK: - TYPOGRAPHY - LOGIN COMPONENTS
    /// Buttons
    var loginButtonFont = UIFont.alfrescoRegularFont(ofSize: 22)
    var loginUtilitiesButtonFont = UIFont.alfrescoRegularFont(ofSize: 14)
    var loginSavePadButtonFont = UIFont.alfrescoRegularFont(ofSize: 17)
    var signOutButtonFont = UIFont.alfrescoRegularFont(ofSize: 14)
    /// Labels
    var productLabelFont = UIFont.alfrescoRegularFont(ofSize: 24)
    var applicationTitleFont = UIFont.alfrescoRegularFont(ofSize: 24)
    var loginCopyrightLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var loginFieldLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var loginHTTPSLabelFont = UIFont.alfrescoRegularFont(ofSize: 17)
    var loginTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 20)
    var loginInfoLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var loginInfoHostnameLabelFont = UIFont.alfrescoRegularFont(ofSize: 14)
    var needHelpTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 24)
    var activityIndicatorLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var settingsTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var settingsSubtitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var listNodeCellTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var listNodeCellSubtitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var emptyListTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 28)
    var emptyListSubtitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var recentSearchesTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 14)
    var recentSearcheTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 16)
    var searchChipTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 12)
    var listNodeSectionTitleLabelFont = UIFont.alfrescoRegularFont(ofSize: 14)
    /// TextFields
    var loginTextFieldFont = UIFont.alfrescoRegularFont(ofSize: 16)
    /// TextViews
    var needHelpHintTextViewFont: UIFont = UIFont.alfrescoRegularFont(ofSize: 14)

    // MARK: - COLORS - LOGIN COMPONENTS
    /// Buttons
    var loginButtonColor = #colorLiteral(red: 0.1764705882, green: 0.5529411765, blue: 0.1568627451, alpha: 1)
    var loginButtonDisableColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
    var loginTextButtonColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var loginNeedHelpButtonColor = #colorLiteral(red: 0.1333333333, green: 0.4156862745, blue: 0.8431372549, alpha: 1)
    var loginAdvancedSettingsButtonColor = #colorLiteral(red: 0.05098039216, green: 0.3882352941, blue: 0.2235294118, alpha: 1)
    var loginSavePadButtonColor = #colorLiteral(red: 0.1764705882, green: 0.5529411765, blue: 0.1568627451, alpha: 1)
    var signOutButtonColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
    var signOutTextButtonColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1568627451, alpha: 1)
    /// Labels
    var productLabelColor = #colorLiteral(red: 0.09803921569, green: 0.09803921569, blue: 0.09803921569, alpha: 1)
    var applicationTitleColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    var loginCopyrightLabelColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    var loginFieldLabelColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    var loginFieldDisableLabelColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    var loginTitleLabelColor = #colorLiteral(red: 0.1254901961, green: 0.1254901961, blue: 0.1254901961, alpha: 1)
    var loginInfoLabelColor = #colorLiteral(red: 0.5215686275, green: 0.5215686275, blue: 0.5215686275, alpha: 1)
    var needHelpTitleColor = #colorLiteral(red: 0.2745098039, green: 0.2745098039, blue: 0.2745098039, alpha: 1)
    var activityIndicatorLabelColor = #colorLiteral(red: 0.568627451, green: 0.568627451, blue: 0.568627451, alpha: 1)
    var settingsTitleLabelColor = #colorLiteral(red: 0.1279757321, green: 0.1371012032, blue: 0.158791095, alpha: 1)
    var settingsSubtitleLabelColor = #colorLiteral(red: 0.5284697413, green: 0.5335359573, blue: 0.5419467092, alpha: 1)
    var listNodeCellTitleLabelColor = #colorLiteral(red: 0.09803921569, green: 0.1019607843, blue: 0.1176470588, alpha: 1)
    var listNodeCellSubtitleLabelColor = #colorLiteral(red: 0.4549019608, green: 0.4588235294, blue: 0.4666666667, alpha: 1)
    var emptyListTitleLabelColor = #colorLiteral(red: 0.1279757321, green: 0.1371012032, blue: 0.158791095, alpha: 1)
    var emptyListSubtitleLabelColor = #colorLiteral(red: 0.3294117647, green: 0.3294117647, blue: 0.3294117647, alpha: 1)
    var recentSearchesTitleLabelColor = #colorLiteral(red: 0.3254901961, green: 0.3254901961, blue: 0.3254901961, alpha: 1)
    var recentSearcheTitleLabelColor = #colorLiteral(red: 0.09803921569, green: 0.1019607843, blue: 0.1176470588, alpha: 1)
    var listNodeSectionTitleLabelColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
    /// TextFields
    var loginTextFieldPrimaryColor = #colorLiteral(red: 0.1764705882, green: 0.5529411765, blue: 0.1568627451, alpha: 1)
    var loginTextFieldErrorColor = #colorLiteral(red: 1, green: 0.2470588235, blue: 0.2666666667, alpha: 1)
    var loginTextFieldOnSurfaceColor = #colorLiteral(red: 0.2078431373, green: 0.2078431373, blue: 0.2078431373, alpha: 1)
    var loginTextFieldIconColor = #colorLiteral(red: 0.7098039216, green: 0.7098039216, blue: 0.7098039216, alpha: 1)
    /// Textviews
    var needHelpHintTextViewColor = #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.2980392157, alpha: 1)
    /// Views
    var backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    var activityIndicatorViewColor = #colorLiteral(red: 0.07236295193, green: 0.6188754439, blue: 0.2596520483, alpha: 1)
    var activityIndicatorSearchViewColor = #colorLiteral(red: 0.137254902, green: 0.3960784314, blue: 0.8549019608, alpha: 1)
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
