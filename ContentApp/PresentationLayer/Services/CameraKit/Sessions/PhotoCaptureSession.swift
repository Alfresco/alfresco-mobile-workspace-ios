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

class PhotoCaptureSession: CaptureSession {
    
    let photoOutput = AVCapturePhotoOutput()
    var flashMode = FlashMode.auto
    
    var cameraPosition = CameraPosition.back {
        didSet {
            do {
                let deviceInput = try CaptureSession.capture(deviceInput: cameraPosition.deviceType)
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
            }
        }
    }
    
    var resolution = CGSize.zero {
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
                AlfrescoLog.error("Something went wrong on resolution \(resolution)")
            }
        }
    }
    
    override var zoom: Double {
        didSet {
            guard let device = captureDeviceInput?.device else {return }
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = CGFloat(self.zoom)
                device.unlockForConfiguration()
            } catch {
                AlfrescoLog.error("Something went wrong on zoom.")
            }
            delegate?.didChange(zoom: zoom)
        }
    }

    // MARK: - Init
    
    init(position: CameraPosition = .back) {
        super.init()
        defer {
            self.cameraPosition = position
        }
        
        self.photoOutput.isHighResolutionCaptureEnabled = true
        let capturePhotoSettings = [AVCapturePhotoSettings(format:
                                                            [AVVideoCodecKey: AVVideoCodecType.jpeg])]
        self.photoOutput.setPreparedPhotoSettingsArray(capturePhotoSettings,
                                                       completionHandler: nil)
        self.session.sessionPreset = .photo
        self.session.addOutput(self.photoOutput)
    }
    
    // MARK: - Capture Methods
    
    override func capture() {
        guard session.isRunning else { return }
        let settings = AVCapturePhotoSettings()
        settings.flashMode = flashMode.captureFlashMode
        settings.isHighResolutionPhotoEnabled = true

        if let connection = photoOutput.connection(with: .video) {
            if resolution.width > 0,
               resolution.height > 0 {
                connection.videoOrientation = .portrait
            } else {
                connection.videoOrientation = UIDevice.current.orientation.videoOrientation
            }
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: - Public Methods
    
    func togglePosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
    }
    
    override func focus(at point: CGPoint) {
        if let device = captureDeviceInput?.device,
           device.isFocusPointOfInterestSupported {
            do {
                try device.lockForConfiguration()
                device.focusPointOfInterest = point
                device.focusMode = .continuousAutoFocus
                if device.isExposurePointOfInterestSupported {
                    device.exposureMode = .autoExpose
                }
                device.unlockForConfiguration()
            } catch let error {
                AlfrescoLog.error("Error while focusing at point \(point): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Private Methods

    private func process(capturePhoto: AVCapturePhoto) {
        guard let data = capturePhoto.fileDataRepresentation() else {
            let error = CaptureError.error("Cannot get photo file data representation")
            AlfrescoLog.error(error)
            delegate?.captured(asset: nil, error: error)
            return
        }
        
        let asset = CapturedAsset(data: data)
        delegate?.captured(asset: asset, error: nil)

//        guard let image = UIImage(data: data) else {
//            let error = CaptureError.error("Cannot get photo")
//            AlfrescoLog.error(error)
//            delegate?.captured(asset: nil, error: error)
//            return
//        }
//
//        if resolution.width > 0,
//           resolution.height > 0,
//            let transformedImage = CameraUtils.cropAndScale(image,
//                                                            width: Int(resolution.width),
//                                                            height: Int(resolution.height),
//                                                            orientation: UIDevice.current.orientation,
//                                                            mirrored: cameraPosition == .front) {
//            let asset = CapturedAsset(image: transformedImage)
//            delegate?.captured(asset: asset, error: nil)
//        } else {
//            let asset = CapturedAsset(image: image)
//            delegate?.captured(asset: asset, error: nil)
//        }
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
        process(capturePhoto: photo)
    }
}
