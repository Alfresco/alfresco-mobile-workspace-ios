//
// Copyright (C) 2005-2021 Alfresco Software Limited.
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

import AVFoundation
import UIKit

enum DeviceType {
    case frontCamera
    case backCamera
    case microphone
    
    var captureDeviceType: AVCaptureDevice.DeviceType {
        switch self {
        case .frontCamera, .backCamera:
            if #available(iOS 13.0, *) {
                if let _ = AVCaptureDevice.default(.builtInTripleCamera, for: AVMediaType.video, position: .back) {
                    return .builtInTripleCamera
                } else if let _ = AVCaptureDevice.default(.builtInDualCamera, for: AVMediaType.video, position: .back) {
                    return .builtInDualCamera
                }
            }
            return .builtInWideAngleCamera
        case .microphone:
            return .builtInMicrophone
        }
    }
    
    var captureMediaType: AVMediaType {
        switch self {
        case .frontCamera, .backCamera:
            return .video
        case .microphone:
            return .audio
        }
    }
    
    var capturePosition: AVCaptureDevice.Position {
        switch self {
        case .frontCamera:
            return .front
        case .backCamera:
            return .back
        case .microphone:
            return .unspecified
        }
    }
}

enum FlashMode {
    case off
    case on // swiftlint:disable:this identifier_name
    case auto
    
    var captureFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .off: return .off
        case .on: return .on
        case .auto: return .auto
        }
    }
    var icon: UIImage? {
        switch self {
        case .off: return UIImage(named: "ic-camera-flash-off")
        case .on: return UIImage(named: "ic-camera-flash-on")
        case .auto: return UIImage(named: "ic-camera-flash-auto")
        }
    }
}

enum CameraPosition {
    case front
    case back
    
    var deviceType: DeviceType {
        switch self {
        case .back:
            return .backCamera
        case .front:
            return .frontCamera
        }
    }
}

enum CaptureError: Error {
    case captureDeviceNotFound
    case error(String)
}
