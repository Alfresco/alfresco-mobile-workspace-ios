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

import CoreLocation
import AVFoundation
import UIKit

class PhotoCaptureSession: CaptureSession {
    
    private let location = CLLocationManager()
    
    let photoOutput = AVCapturePhotoOutput()
    var flashMode = FlashMode.auto
    
    var cameraPosition = CameraPosition.back {
        didSet {
            do {
                let deviceInput = try CaptureSession.capture(deviceInput: cameraPosition.deviceType)
                zoom = naturalZoomFactor
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
    
    override var aspectRatio: CameraAspectRatio {
        didSet {
            resolution = aspectRatio.size
        }
    }
    
    override var resolution: CGSize {
        didSet {
            guard let deviceInput = captureDeviceInput else { return }
            do {
                try deviceInput.device.lockForConfiguration()
                if let format = CaptureSession.device(input: deviceInput,
                                                      resolution: resolution) {
                    deviceInput.device.activeFormat = format
                } else {
                    session.sessionPreset = .photo
                }
                deviceInput.device.unlockForConfiguration()
            } catch {
                AlfrescoLog.error("An unexpected error occured while setting the camera resolution to \(resolution)")
            }
        }
    }
    
    override var zoom: Float {
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

    var naturalZoomFactor: Float {
        return Float(captureDeviceInput?.device.neutralZoomFactor ?? 1.0)
    }

    // MARK: - Init
    
    init(position: CameraPosition = .back) {
        super.init()
        defer {
            self.cameraPosition = position
        }
        
        self.photoOutput.isHighResolutionCaptureEnabled = true
        let format = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        let capturePhotoSettings = [AVCapturePhotoSettings(format: format)]
        self.photoOutput.setPreparedPhotoSettingsArray(capturePhotoSettings,
                                                       completionHandler: nil)
        self.session.sessionPreset = .photo
        self.session.addOutput(self.photoOutput)
    }
    
    // MARK: - Capture Methods
    
    override func capture() {
        guard session.isRunning else { return }
        let settings = AVCapturePhotoSettings()
        if let device = captureDeviceInput?.device, device.hasFlash {
            settings.flashMode = flashMode.captureFlashMode
        }
        settings.isHighResolutionPhotoEnabled = true

        if let connection = photoOutput.connection(with: .video) {
            connection.videoOrientation = orientationLast.captureOrientation
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Public Methods
    
    func resetDeviceConfiguration() {
        if let device = captureDeviceInput?.device {
            defaultConfiguration(for: device)
        }
    }
    
    func togglePosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
    }
    
    override func focus(at point: CGPoint) -> Bool {
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
    
    // MARK: - Private Methods

    private func process(capturedPhoto: AVCapturePhoto) {
        guard let data = getFileRepresentationWithLocationData(photo: capturedPhoto),
              let mediaFolderPath = mediaFilesFolderPath else {
            let error = CaptureError.error("Cannot process captured photo")
            AlfrescoLog.error(error)
            delegate?.captured(asset: nil, error: error)

            return
        }

        delegate?.captured(asset: CapturedAsset(type: .image,
                                                fileName: defaultFileName(),
                                                data: data,
                                                saveIn: mediaFolderPath),
                           error: nil)
    }
    
    private func defaultConfiguration(for device: AVCaptureDevice) {
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

    private func defaultFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(prefixFileName)_\(dateFormatter.string(from: Date()))"
    }
}

extension PhotoCaptureSession: AVCapturePhotoFileDataRepresentationCustomizer {
    
    func replacementMetadata(for photo: AVCapturePhoto) -> [String: Any]? {
        var properties = photo.metadata
        if let gpsDictionary = location.gpsLocation() {
            properties[kCGImagePropertyGPSDictionary as String] = gpsDictionary
        }
        return properties
    }
    
    // MARK: - GPS Location
    
    func getFileRepresentationWithLocationData(photo: AVCapturePhoto) -> Data? {
        var properties = photo.metadata
        if let gpsDictionary = location.gpsLocation() {
            properties[kCGImagePropertyGPSDictionary as String] = gpsDictionary
        }
        return photo.fileDataRepresentation(with: self)
    }
}

// MARK: - AVCapturePhotoCapture Delegate

extension PhotoCaptureSession: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        if let error = error {
            delegate?.captured(asset: nil, error: error)
        }
        process(capturedPhoto: photo)
    }
}
