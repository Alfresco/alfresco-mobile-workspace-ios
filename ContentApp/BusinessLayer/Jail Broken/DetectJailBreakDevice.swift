//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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
import UIKit

// Protocol function
//
// sendTheStatusOfJailBreak:- True/ False value to be send if device is JailBreak
//
public protocol Check_Method_Of_JailBreak: AnyObject {
    func sendTheStatusOfJailBreak(value: Bool)
}

// Constant of FileManager path
let fileManager = FileManager.default

// isSimulator - Returns true if it is run on Simulator
private var isSimulator: Bool {
    return TARGET_OS_SIMULATOR != 0
}

// Array - filesPathToCheck
//
// Important files and App to check if the device is jailBroken
//
private var filesPathToCheck: [String] {
    
    return ["/private/var/lib/apt",
            "/Applications/Cydia.app",
            "/private/var/lib/cydia",
            "/private/var/tmp/cydia.log",
            "/Applications/RockApp.app",
            "/Applications/Icy.app",
            "/Applications/WinterBoard.app",
            "/Applications/SBSetttings.app",
            "/Applications/blackra1n.app",
            "/Applications/IntelliScreen.app",
            "/Applications/Snoop-itConfig.app",
            "/usr/libexec/cydia/",
            "/usr/sbin/frida-server",
            "/usr/bin/cycript",
            "/usr/local/bin/cycript",
            "/usr/lib/libcycript.dylib",
            "/bin/sh",
            "/usr/libexec/sftp-server",
            "/usr/libexec/ssh-keysign",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/usr/bin/ssh",
            "/bin.sh",
            "/var/checkra1n.dmg",
            "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist"]
    
}

private let jailBreakTestText = "Test for JailBreak"

// enum - TypeOfJailBreakCheckAPI
//
// Developer can select which func call they want to check for jail break detection
// Either readWrite or systemCalls
// It is preferabble to call readAndWrite func
//
public enum TypeOfJailBreakCheckAPI {
    case readAndWriteFiles, systemCalls
    mutating public func assignJailBreakCheckType(type: TypeOfJailBreakCheckAPI) {
        switch self {
        case .readAndWriteFiles:
            self = .readAndWriteFiles
        case .systemCalls:
            self = .systemCalls
            
        }
    }
}

public extension Check_Method_Of_JailBreak {
    
    // Protocol function extended for JailBreak detection
    //
    func assignJailBreakCheckType(type: TypeOfJailBreakCheckAPI) {
        // If it is run on simulator follow the regular flow of the app
        if !isSimulator {
            // Check if Cydia app is installed on the device
            guard UIApplication.shared.canOpenURL(URL(string: "cydia://")!) else {
                
                let checkStatus = type == .readAndWriteFiles ? canEditSandboxFilesForJailBreakDetection() : systemForkCall()
                
                self.sendTheStatusOfJailBreak(value: checkStatus)
                return
            }
            self.sendTheStatusOfJailBreak(value: true)
        }
        self.sendTheStatusOfJailBreak(value: false)
    }
    
    // func - canEditSandboxFilesForJailBreakDetecttion
    //
    // It tries to write into system files
    // If it is able to write files then it is JailBroken device
    //
    func canEditSandboxFilesForJailBreakDetection() -> Bool {
        let jailBreakTestText = "Test for JailBreak"
        do {
            try jailBreakTestText.write(toFile: "/private/jailBreakTestText.txt", atomically: true, encoding: String.Encoding.utf8)
            return true
        } catch {
            let resultJailBroken = isJailBrokenFilesPresentInTheDirectory()
            return resultJailBroken
        }
    }
    
    // func - isJailBrokenFilesPresentInTheDirectory
    //
    // It checks from the array 'filesPathToCheck' that particular file or app
    // are installed on the device
    // If file exist then it is jail broken
    //
    func isJailBrokenFilesPresentInTheDirectory() -> Bool {
        var checkFileIfExist = false
        filesPathToCheck.forEach {
            checkFileIfExist =  fileManager.fileExists(atPath: $0) ? true : false
            if checkFileIfExist {
                return
            }
        }
        
        return checkFileIfExist
    }
    
    // func:- systemForkCall
    //
    // It is used to check if there is a child process run at kernel level
    //
    func systemForkCall() -> Bool {
        
        let pid = getpgrp()
        if pid < 0 {
            return true
        } else {
            return false
        }
    }
}
