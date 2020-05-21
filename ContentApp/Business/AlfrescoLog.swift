//
//  AlfrescoLog.swift
//  ContentApp
//
//  Created by Florin Baincescu on 21/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import Foundation
import os.log

class AlfrescoLog {
    class func error(_ message: String) {
        os_log(.error, log: .default, "%@", message)
        
    }
    
    class func info(_ message: String) {
        os_log(.info, log: .default, "%@", message)
    }
    
    class func debug(_ message: String) {
        os_log(.debug, log: .default, "%@", message)
    }
}
