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
    /// Buttons
    var loginButtonFont: UIFont { get }
    var loginUtilitiesButtonFont: UIFont { get }
    var loginSavePadButtonFont: UIFont { get }
    var signOutButtonFont: UIFont { get }
    /// Labels
    var productLabelFont: UIFont { get }
    var applicationTitleFont: UIFont { get }
    var loginCopyrightLabelFont: UIFont { get }
    var loginFieldLabelFont: UIFont { get }
    var loginHTTPSLabelFont: UIFont { get }
    var loginTitleLabelFont: UIFont { get }
    var loginInfoLabelFont: UIFont { get }
    var loginInfoHostnameLabelFont: UIFont { get }
    var needHelpTitleLabelFont: UIFont { get }
    var activityIndicatorLabelFont: UIFont { get }
    var settingsTitleLabelFont: UIFont { get }
    var settingsSubtitleLabelFont: UIFont { get }
    var emptyListTitleLabelFont: UIFont { get }
    var emptyListSubtitleLabelFont: UIFont { get }
    /// TextFields
    var loginTextFieldFont: UIFont { get }
    /// Textviews
    var needHelpHintTextViewFont: UIFont { get }

    // COLORS - LOGIN COMPONENTS
    /// Buttons
    var loginButtonColor: UIColor { get }
    var loginTextButtonColor: UIColor { get }
    var loginButtonDisableColor: UIColor { get }
    var loginNeedHelpButtonColor: UIColor { get }
    var loginAdvancedSettingsButtonColor: UIColor { get }
    var loginSavePadButtonColor: UIColor { get }
    var signOutButtonColor: UIColor { get }
    var signOutTextButtonColor: UIColor { get }
    /// Labels
    var productLabelColor: UIColor { get }
    var applicationTitleColor: UIColor { get }
    var loginCopyrightLabelColor: UIColor { get }
    var loginFieldLabelColor: UIColor { get }
    var loginInfoLabelColor: UIColor { get }
    var loginFieldDisableLabelColor: UIColor { get }
    var loginTitleLabelColor: UIColor { get }
    var needHelpTitleColor: UIColor { get }
    var activityIndicatorLabelColor: UIColor { get }
    var settingsTitleLabelColor: UIColor { get }
    var settingsSubtitleLabelColor: UIColor { get }
    var emptyListTitleLabelColor: UIColor { get }
    var emptyListSubtitleLabelColor: UIColor { get }

    /// TextFields
    var loginTextFieldPrimaryColor: UIColor { get }
    var loginTextFieldErrorColor: UIColor { get }
    var loginTextFieldOnSurfaceColor: UIColor { get }
    var loginTextFieldIconColor: UIColor { get }
    /// Textviews
    var needHelpHintTextViewColor: UIColor { get }
    /// Views
    var backgroundColor: UIColor { get }
    var activityIndicatorViewColor: UIColor { get }
    var snackbarErrorColor: UIColor { get }
    var snackbarApproved: UIColor { get }
    var snackbarWarning: UIColor { get }
    var settingsIconColor: UIColor { get }
}
