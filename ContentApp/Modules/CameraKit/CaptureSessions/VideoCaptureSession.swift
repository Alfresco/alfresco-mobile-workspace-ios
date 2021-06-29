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

class VideoCaptureSession: CaptureSession {
    
    var isRecording = false
    var videoFileName: String?
    let movieOutput = AVCaptureMovieFileOutput()
    let sessionPresets: [AVCaptureSession.Preset] = [.hd4K3840x2160, .hd1920x1080, .hd1280x720, .vga640x480]
    
    override var flashMode: FlashMode {
        didSet {
            guard let device = captureDeviceInput?.device else { return }
            
            do {
                try device.lockForConfiguration()
                if device.isTorchModeSupported(flashMode.captureTorchMode) {
                    device.torchMode = flashMode.captureTorchMode
                }
                device.unlockForConfiguration()
            } catch {
                AlfrescoLog.error("An unexpected error occured while activated tourch.")
            }
        }
    }
    
    // MARK: - Init
    
    init(position: CameraPosition = .back, aspectRatio: CameraAspectRatio = .ar16by9) {
        super.init()
        
        defer {
            self.cameraPosition = position
            self.aspectRatio = aspectRatio
            
            if let deviceInput = captureDeviceInput {
                updateSessionPreset(for: deviceInput)
            }
        }
        
        do {
            let microphoneInput = try CaptureSession.capture(deviceInput: .microphone)
            session.addInput(microphoneInput)
        } catch let error {
            AlfrescoLog.error(error)
        }
        
        session.addOutput(movieOutput)
    }
    
    // MARK: - Public Methods
    
    override func capture() {
        if isRecording {
            movieOutput.stopRecording()
            return
        }
        
        guard let mediaFolderPath = mediaFilesFolderPath else { return }
        
        var videoURL = URL(fileURLWithPath: mediaFolderPath)
        let fileName = defaultFileName(with: prefixVideoFileName)
        videoFileName = fileName
        videoURL.appendPathComponent("\(fileName).\(extVideo)")
        if let connection = movieOutput.connection(with: .video) {
            connection.videoOrientation = lastOrientation.captureOrientation
        }
        addGPSLocationData()
        movieOutput.startRecording(to: videoURL, recordingDelegate: self)
    }
    
    override func shouldDisplayFlashMode() -> Bool {
        return captureDeviceInput?.device.hasTorch ?? false
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
            let cmTime = CMTime(value: 1, timescale: aspectRatio.frameRate)
            deviceInput.device.activeVideoMinFrameDuration = cmTime
            deviceInput.device.activeVideoMaxFrameDuration = cmTime
            deviceInput.device.unlockForConfiguration()
        } catch {
            AlfrescoLog.error("An unexpected error occured while setting the camera resolution to \(resolution)")
        }
    }
    
    // MARK: - Private Methods
    
    private func addGPSLocationData() {
        guard let gpsDictionary = CameraKit.location else { return }
        
        let gpsProperties = AVMutableMetadataItem()
        gpsProperties.identifier = .quickTimeMetadataLocationISO6709
        gpsProperties.value = gpsDictionary as (NSCopying & NSObjectProtocol)?
        gpsProperties.dataType = AVMetadataIdentifier.quickTimeMetadataLocationISO6709.rawValue
        movieOutput.metadata?.append(gpsProperties)
    }
}

// MARK: AVCaptureFileOutputRecording Delegate

extension VideoCaptureSession: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didStartRecordingTo fileURL: URL,
                    from connections: [AVCaptureConnection]) {
        isRecording = true
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        isRecording = false
        if let error = error {
            delegate?.captured(asset: nil, error: error)
        } else {
            let filename = videoFileName ?? defaultFileName(with: prefixVideoFileName)
            delegate?.captured(asset: CapturedAsset(type: .video,
                                                    fileName: filename,
                                                    path: outputFileURL.path),
                               error: nil)
        }
    }
}