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

protocol CaptureSessionDelegate: class {
    func captured(asset: CapturedAsset?, error: Error?)
    func didChange(zoom: Double)
}

class CaptureSession: NSObject {
    let session: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer?
    var overlayView: UIView?
    var zoom = 1.0
    weak var delegate: CaptureSessionDelegate?
    
    // MARK: - Init

    override init() {
        self.session = AVCaptureSession()
    }
    
    // MARK: - Public Methods
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func focus(at point: CGPoint) {
    }
    
    func capture() {
    }
    
    // MARK: - Static Public Methods
    
    static func capture(deviceInput type: DeviceType) throws -> AVCaptureDeviceInput {
        let captureDevices = AVCaptureDevice.DiscoverySession(
            deviceTypes: [type.captureDeviceType],
            mediaType: type.captureMediaType,
            position: type.capturePosition)
        
        guard let captureDevice = captureDevices.devices.first else {
            throw CaptureError.captureDeviceNotFound
        }
        
        return try AVCaptureDeviceInput(device: captureDevice)
    }
    
    static func device(input: AVCaptureDeviceInput,
                       resolution: CGSize,
                       frameRate: Int = 30) -> AVCaptureDevice.Format? {

        let width = Int(resolution.width)
        let height = Int(resolution.height)
        guard width > 0, height > 0 else { return nil }

        for format in input.device.formats {
            let dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription)
            if dimension.width >= width && dimension.height >= height {
                for range in format.videoSupportedFrameRateRanges {
                    if Int(range.maxFrameRate) >= frameRate &&
                        Int(range.minFrameRate) <= frameRate {
                        return format
                    }
                }
            }
        }
        return nil
    }
}
