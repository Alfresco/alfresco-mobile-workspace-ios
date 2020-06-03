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

struct LocalizationConstants {
    static let copyright = NSLocalizedString("copyrightFormat", comment: "")
    static let productName = NSLocalizedString("productName", comment: "")

    struct Buttons {
        static let connect = NSLocalizedString("connectButton", comment: "")
        static let advancedSetting = NSLocalizedString("advancedSettingButton", comment: "")
        static let needHelp = NSLocalizedString("needHelpButton", comment: "")
        static let resetToDefault = NSLocalizedString("resetToDefaultButton", comment: "")
        static let save = NSLocalizedString("saveButton", comment: "")
        static let signin = NSLocalizedString("signin", comment: "")
        static let signInWithSSO = NSLocalizedString("signInWithSSO", comment: "")
    }

    struct TextFieldPlaceholders {
        static let connect = NSLocalizedString("loginConnectTextFieldPlaceholder", comment: "")
        static let port = NSLocalizedString("loginPortTextFieldPlaceholder", comment: "")
        static let serviceDocuments = NSLocalizedString("loginServiceDocumentsTextFieldPlaceholder", comment: "")
        static let realm = NSLocalizedString("loginRealmTextFieldPlaceholder", comment: "")
        static let clientID = NSLocalizedString("loginClientIDTextFieldPlaceholder", comment: "")
        static let username = NSLocalizedString("loginUsernameTextFieldPlaceholder", comment: "")
        static let repository = NSLocalizedString("loginRepositoryTextFieldPlaceholder", comment: "")
        static let password = NSLocalizedString("loginPasswordTextFieldPlaceholder", comment: "")
    }

    struct Labels {
        static let transportProtocol = NSLocalizedString("loginTransportProtocolLabel", comment: "")
        static let https = NSLocalizedString("https", comment: "")
        static let alfrescoContentServicesSettings = NSLocalizedString("alfrescoContentServicesSettings", comment: "")
        static let authentication = NSLocalizedString("authentication", comment: "")
        static let infoConnectTo = NSLocalizedString("infoConnectTo", comment: "")
        static let allowSSO = NSLocalizedString("loginAllowSSO", comment: "")
        static let needHelpTitle = NSLocalizedString("needHelpTitle", comment: "")
        static let conneting = NSLocalizedString("connecting", comment: "")
        static let signingIn = NSLocalizedString("signingIn", comment: "")
    }

    struct ScreenTitles {
        static let advancedSettings = NSLocalizedString("advancedSettings", comment: "")
    }

    struct Textviews {
        static let serviceURLHint = NSLocalizedString("serviceURLHint", comment: "")
        static let advancedSettingsHint = NSLocalizedString("advancedSettingsHint", comment: "")
        static let ssoHint = NSLocalizedString("ssoHint", comment: "")
    }
}
