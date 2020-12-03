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

import Foundation

/**
 The theming scenes enum structure is intended to be used as a component identifier in a particular UI
 setup.
 - Note: Basic convetion for creating a scene enum value is to referene a UI component from a scene
 or screen. Eg. a scene for the login button would be *loginButton*. If variations for that specific components
 are available you could construct it by specifyng the intent as well i.e. *identityServiceLoginButton*.
*/
enum MaterialComponentsThemingScene {
    case loginTextField
    case loginButton
    case loginAdvancedSettingsButton
    case loginNeedHelpButton
    case loginResetButton
    case loginSavePadButton
    case signOutButton
    case searchChipSelected
    case searchChipUnselected
    case favoritesTabBar
    case applicationTabBar
    case pdfPasswordDialog
    case dialogButton
}
