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
    let sessionPresets: [AVCaptureSession.Preset] = [.photo]
    
    // MARK: - Init
    
    init(position: CameraPosition = .back, aspectRatio: CameraAspectRatio = .ar4by3) {
        super.init()
        defer {
            cameraPosition = position
            self.aspectRatio = aspectRatio
        }
        
        photoOutput.isHighResolutionCaptureEnabled = true
        let format = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        let capturePhotoSettings = [AVCapturePhotoSettings(format: format)]
        photoOutput.setPreparedPhotoSettingsArray(capturePhotoSettings,
                                                       completionHandler: nil)
        session.addOutput(photoOutput)
    }
    
    // MARK: - Public Methods
    
    override func capture() {
        guard session.isRunning else { return }
        let settings = AVCapturePhotoSettings()
        if let device = captureDeviceInput?.device, device.hasFlash {
            settings.flashMode = flashMode.captureFlashMode
        }
        settings.isHighResolutionPhotoEnabled = true

        if let connection = photoOutput.connection(with: .video) {
            connection.videoOrientation = lastOrientation.captureOrientation
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    override func shouldDisplayFlashMode() -> Bool {
        return captureDeviceInput?.device.hasFlash ?? false
    }
    
    override func updateSessionPreset(for deviceInput: AVCaptureDeviceInput) {
        do {
            try deviceInput.device.lockForConfiguration()
            for preset in sessionPresets {
                if deviceInput.device.supportsSessionPreset(preset) {
                    session.sessionPreset = preset
                    break
                }
            }
            deviceInput.device.unlockForConfiguration()
        } catch {
            AlfrescoLog.error("An unexpected error occured while setting the camera resolution")
        }
    }

    // MARK: - Private Methods

    private func process(capturedPhoto: AVCapturePhoto) {
        guard let data = fileRepresentationWithLocationData(for: capturedPhoto),
              let mediaFolderPath = mediaFilesFolderPath else {
            let error = CaptureError.error("Cannot process captured photo")
            AlfrescoLog.error(error)
            delegate?.captured(asset: nil, error: error)

            return
        }

        delegate?.captured(asset: CapturedAsset(type: .image,
                                                fileName: defaultFileName(with: prefixImageFileName),
                                                data: data,
                                                saveIn: mediaFolderPath),
                           error: nil)
    }
}

extension PhotoCaptureSession: AVCapturePhotoFileDataRepresentationCustomizer {
    
    func replacementMetadata(for photo: AVCapturePhoto) -> [String: Any]? {
        var properties = photo.metadata
        if let gpsDictionary = CameraKit.location {
            properties[kCGImagePropertyGPSDictionary as String] = gpsDictionary
        }
        return properties
    }
    
    // MARK: - GPS Location
    
    func fileRepresentationWithLocationData(for photo: AVCapturePhoto) -> Data? {
        var properties = photo.metadata
        if let gpsDictionary = CameraKit.location {
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
