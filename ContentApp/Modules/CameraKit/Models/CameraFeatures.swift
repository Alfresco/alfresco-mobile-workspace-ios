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

enum CameraAspectRatio {
    case ar4by3
    case ar16by9
    
    var value: CGFloat {
        switch self {
        case .ar4by3:
            if UIDevice.current.orientation.isLandscape &&
                UIDevice.current.userInterfaceIdiom == .pad {
                return CGFloat(3.0 / 4.0)
            } else {
                return CGFloat(4.0 / 3.0)
            }
        case .ar16by9:
            if UIDevice.current.orientation.isLandscape &&
                UIDevice.current.userInterfaceIdiom == .pad {
                return CGFloat(9.0 / 16.0)
            } else {
                return CGFloat(16.0 / 9.0)
            }
        }
    }
    
    var size: CGSize {
        switch self {
        case .ar4by3:
            if UIDevice.current.orientation.isLandscape &&
                UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: 4032, height: 3024)
            } else {
                return CGSize(width: 3024, height: 4032)
            }
        case .ar16by9:
            if UIDevice.current.orientation.isLandscape &&
                UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: 3840, height: 2160)
            } else {
                return CGSize(width: 2160, height: 3840)
            }
        }
    }
}

enum DeviceType {
    case frontCamera
    case backCamera
    case microphone
    
    var captureDeviceType: AVCaptureDevice.DeviceType {
        switch self {
        case .backCamera:
            if let _ = AVCaptureDevice.default(.builtInTripleCamera,
                                               for: AVMediaType.video,
                                               position: .back) {
                return .builtInTripleCamera
            } else if let _ = AVCaptureDevice.default(.builtInDualCamera,
                                                      for: AVMediaType.video,
                                                      position: .back) {
                return .builtInDualCamera
            } else {
                return .builtInWideAngleCamera
            }
        case .frontCamera:
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
    
    var captureTorchMode: AVCaptureDevice.TorchMode {
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
