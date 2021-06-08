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
import CoreMotion

protocol CaptureSessionDelegate: AnyObject {
    func captured(asset: CapturedAsset?, error: Error?)
}

protocol CaptureSessionUIDelegate: AnyObject {
    func didChange(zoom: Float)
    func didChange(orientation: UIImage.Orientation)
}

class CaptureSession: NSObject {
    let session: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer?
    var overlayView: UIView?
    var resolution = CGSize.zero
    var aspectRatio = CameraAspectRatio.ar4by3
    var zoom: Float = 1.0
    var mediaFilesFolderPath: String?
    weak var delegate: CaptureSessionDelegate?
    weak var uiDelegate: CaptureSessionUIDelegate?
    var lastOrientation = UIDevice.current.orientation

    private var motionManager: CMMotionManager?
    
    // MARK: - Init

    override init() {
        self.session = AVCaptureSession()
        super.init()
        self.initializeMotionManager()
    }
    
    // MARK: - Public Methods
    
    func start() {
        session.startRunning()
    }
    
    func stop() {
        session.stopRunning()
    }
    
    func focus(at point: CGPoint) -> Bool {
        return false
    }
    
    func capture() {
    }
    
    func deviceOrientationChanged() {
        resolution = aspectRatio.size
    }
    
    // MARK: - Private Methods
    
    func initializeMotionManager() {
        guard let operation = OperationQueue.current else { return }
        motionManager = CMMotionManager()
        motionManager?.accelerometerUpdateInterval = 0.2
        motionManager?.gyroUpdateInterval = 0.2
        motionManager?
            .startAccelerometerUpdates(to: operation,
                                       withHandler: { [weak self] (accelerometer, error) in
                                        guard let sSelf = self else { return }
            if let error = error {
                AlfrescoLog.error("CMMotionManager fail, error: \(error.localizedDescription)")
            } else if let acceleration = accelerometer?.acceleration {
                sSelf.outputAccelertionData(acceleration)
            }
        })
    }
    
    func outputAccelertionData(_ acceleration: CMAcceleration) {
        var newOrientation: UIDeviceOrientation
        if acceleration.x >= 0.75 {
            newOrientation = .landscapeLeft
        } else if acceleration.x <= -0.75 {
            newOrientation = .landscapeRight
        } else if acceleration.y <= -0.75 {
            newOrientation = .portrait
        } else if acceleration.y >= 0.75 {
            newOrientation = .portraitUpsideDown
        } else {
            return
        }
        if newOrientation == lastOrientation {
            return
        }
        lastOrientation = newOrientation
        uiDelegate?.didChange(orientation: lastOrientation.imageOrientation)
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
