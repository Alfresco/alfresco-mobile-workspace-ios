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
    
    var flashMode = FlashMode.off

    var zoom: Float = 1.0 {
        didSet {
            guard let device = captureDeviceInput?.device else { return }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = CGFloat(zoom)
                device.unlockForConfiguration()
            } catch {
                AlfrescoLog.error("An unexpected error occured while zooming.")
            }
            uiDelegate?.didChange(zoom: zoom)
        }
    }
    var aspectRatio = CameraAspectRatio.ar4by3
    var naturalZoomFactor: Float {
        return Float(captureDeviceInput?.device.neutralZoomFactor ?? 1.0)
    }
    var cameraPosition = CameraPosition.back {
        didSet {
            do {
                let deviceInput = try CaptureSession.capture(deviceInput: cameraPosition.deviceType)
                zoom = naturalZoomFactor
                updateSessionPreset(for: deviceInput)
                captureDeviceInput = deviceInput
            } catch let error {
                AlfrescoLog.error(error)
            }
        }
    }
    var captureDeviceInput: AVCaptureDeviceInput? {
        didSet {
            if let oldValue = oldValue {
                session.removeInput(oldValue)
            }
            if let captureDeviceInput = captureDeviceInput {
                session.addInput(captureDeviceInput)
                defaultConfiguration(for: captureDeviceInput.device)
            }
        }
    }
    
    weak var delegate: CaptureSessionDelegate?
    weak var uiDelegate: CaptureSessionUIDelegate?

    var lastOrientation = UIDevice.current.orientation
    var mediaFilesFolderPath: String?

    private var motionManager: CMMotionManager?
    
    // MARK: - Init

    deinit {
        session.stopRunning()
    }

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
    
    func capture() {
    }
    
    func toggleCameraPosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
    }
    
    func shouldDisplayFlashMode() -> Bool {
        return false
    }
    
    func updateSessionPreset(for deviceInput: AVCaptureDeviceInput) {
    }
    
    func focus(at point: CGPoint) -> Bool {
        var shouldDisplayFocus = false
        if let device = captureDeviceInput?.device,
           device.isFocusPointOfInterestSupported {
            do {
                try device.lockForConfiguration()
                shouldDisplayFocus = true
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
                if device.isSmoothAutoFocusSupported {
                    device.isSmoothAutoFocusEnabled = true
                }
                if device.isExposurePointOfInterestSupported {
                    device.exposureMode = .autoExpose
                }
                let whiteBalanceMode: AVCaptureDevice.WhiteBalanceMode = .continuousAutoWhiteBalance
                if device.isWhiteBalanceModeSupported(whiteBalanceMode) {
                    device.whiteBalanceMode = whiteBalanceMode
                }
                device.unlockForConfiguration()
            } catch let error {
                AlfrescoLog.error("Error while focusing at point \(point): \(error.localizedDescription)")
            }
        }
        return shouldDisplayFocus
    }
    
    func resetDeviceConfiguration() {
        if let device = captureDeviceInput?.device {
            defaultConfiguration(for: device)
        }
    }
    
    func defaultConfiguration(for device: AVCaptureDevice) {
        do {
            try device.lockForConfiguration()

            let focusMode: AVCaptureDevice.FocusMode = .continuousAutoFocus
            let exposureMode: AVCaptureDevice.ExposureMode = .continuousAutoExposure
            let whitebalanceMode: AVCaptureDevice.WhiteBalanceMode = .continuousAutoWhiteBalance

            if device.isFocusModeSupported(focusMode) {
                device.focusMode = focusMode
            }
            if device.isExposureModeSupported(exposureMode) {
                device.exposureMode = exposureMode
            }

            if device.isWhiteBalanceModeSupported(whitebalanceMode) {
                device.whiteBalanceMode = .continuousAutoWhiteBalance
            }

            device.unlockForConfiguration()
        } catch {
            AlfrescoLog.error("An unexpected error occured while zooming.")
        }
    }
    
    func defaultFileName(with prefix: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(prefix)_\(dateFormatter.string(from: Date()))"
    }
    
    // MARK: - CMMotion Manager
    
    private func initializeMotionManager() {
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
}
