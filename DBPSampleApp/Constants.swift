//
//  Constants.swift
//  DBPSampleApp
//
//  Created by Florin Baincescu on 12/08/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import Foundation
import UIKit

let appDelegate = (UIApplication.shared.delegate as? AppDelegate)

// Login screen
let kAlfrescoDocsURL = "https://docs.alfresco.com"

// Advanced settings screen
let kContentURL = "content.alfresco.com"
let kProcessURL = "process.alfresco.com"
let kRealm      = "alfresco"
let kClientID   = "alfresco"
let kRedirectURI = "iosapp://fake.url.here/auth"

// Segue identifiers
let kSegueAdvancedSettingsViewController = "AdvancedSettingsViewControllerSegue"
let kSegueAuthenticatedViewController = "AuthenticatedViewControllerSegue"
