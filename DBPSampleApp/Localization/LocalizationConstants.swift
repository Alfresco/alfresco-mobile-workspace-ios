//
//  LocalizationConstants.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 08/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation

struct LocalizationConstants {
    struct LoginIdentifiers {
        static let uiAlfrescoURL        = NSLocalizedString("uiAlfrescoURL", comment: "")
        static let uiLoginHTTPS         = NSLocalizedString("uiLoginHTTPS", comment: "")
        static let uiLogin              = NSLocalizedString("uiLogin", comment: "")
        static let uiAdvancedSettings   = NSLocalizedString("uiAdvancedSettings", comment: "")
        static let uiHelp               = NSLocalizedString("uiHelp", comment: "")
        static let msgDidLogIn          = NSLocalizedString("msgDidLogIn", comment: "")
    }
    
    struct LoginAdvancedSettingsIdentifiers {
        static let uiContentURL         = NSLocalizedString("uiContentURL", comment: "")
        static let uiProcessURL         = NSLocalizedString("uiProcessURL", comment: "")
        static let uiRealm              = NSLocalizedString("uiRealm", comment: "")
        static let uiClientID           = NSLocalizedString("uiClientID", comment: "")
        static let uiRedirectURI        = NSLocalizedString("uiRedirectURI", comment: "")
        static let msgDidSavedLoginParams = NSLocalizedString("msgDidSavedLoginParams", comment: "")
    }
    
    struct AuthenticatedIdentifiers {
        static let uiRefreshSession     = NSLocalizedString("uiRefreshSession", comment: "")
        static let msgSessionRefresh    = NSLocalizedString("msgSessionRefresh", comment: "")
        static let msgLoggedOut         = NSLocalizedString("msgLoggedOut", comment: "")
    }
}
