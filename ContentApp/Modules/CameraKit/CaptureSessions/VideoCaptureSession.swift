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
    let movieOutput = AVCaptureMovieFileOutput()
    var videoFileName: String?
    
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
    
    var flashMode = FlashMode.auto {
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
                let cmTime = CMTime(value: 1, timescale: aspectRatio.frameRate)
                deviceInput.device.activeVideoMinFrameDuration = cmTime
                deviceInput.device.activeVideoMaxFrameDuration = cmTime
                deviceInput.device.unlockForConfiguration()
            } catch {
                AlfrescoLog.error("An unexpected error occured while setting the camera resolution to \(resolution)")
            }
        }
    }
    
    // MARK: - Init
    
    init(position: CameraPosition = .back) {
        super.init()
        
        defer {
            cameraPosition = position
            do {
                let microphoneInput = try CaptureSession.capture(deviceInput: .microphone)
                session.addInput(microphoneInput)
            } catch let error {
                AlfrescoLog.error(error)
            }
        }
        
        session.sessionPreset = .photo
        session.addOutput(movieOutput)
    }
    
    // MARK: - Public Methods
    
    override func capture() {
        guard !isRecording,
              let mediaFolderPath = mediaFilesFolderPath else { return }
        
        var videoURL = URL(fileURLWithPath: mediaFolderPath)
        let fileName = defaultFileName()
        videoFileName = fileName
        videoURL.appendPathComponent("\(fileName).\(extVideo)")
        if let connection = movieOutput.connection(with: .video) {
            connection.videoOrientation = lastOrientation.captureOrientation
        }
        
        movieOutput.startRecording(to: videoURL, recordingDelegate: self)
    }
    
    func stopRecording() {
        movieOutput.stopRecording()
    }
    
    func togglePosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
    }
    
    // MARK: - Private Methods
    
    private func defaultFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        return "\(prefixVideoFileName)_\(dateFormatter.string(from: Date()))"
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
            delegate?.captured(asset: CapturedAsset(type: .video,
                                                    fileName: videoFileName ?? defaultFileName(),
                                                    path: outputFileURL.path),
                               error: nil)
        }
    }
}
