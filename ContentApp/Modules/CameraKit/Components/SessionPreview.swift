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

class SessionPreview: UIView {
    private var focusView: UIImageView?
    private var lastScale = minZoom
    private var focusTimer: Timer?
    
    private(set) var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let previewLayer = previewLayer {
                layer.addSublayer(previewLayer)
            }
        }
    }
    
    private var session: CaptureSession? {
        didSet {
            oldValue?.stop()
            if let session = session {
                previewLayer = AVCaptureVideoPreviewLayer(session: session.session)
                session.previewLayer = previewLayer
                session.overlayView = self
                session.start()
            }
        }
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        previewLayer?.connection?.videoOrientation = .portrait
    }
    
    // MARK: - Public Methods
    
    func add(session: CaptureSession) {
        self.session = session
    }
    
    func startSession() {
        session?.start()
    }
    
    func stopSession() {
        session?.stop()
    }
    
    func capture() {
        session?.capture()
    }
    
    func nextFlashMode() {
        if let photoSession = session as? PhotoCaptureSession {
            switch photoSession.flashMode {
            case .auto: photoSession.flashMode = .off
            case .off: photoSession.flashMode = .on
            case .on: photoSession.flashMode = .auto
            }
        }
    }
    
    func flashModeIcon() -> UIImage? {
        if let photoSession = session as? PhotoCaptureSession {
            return photoSession.flashMode.icon
        }
        return nil
    }
    
    func changeCameraPosition() {
        if let photoSession = session as? PhotoCaptureSession {
            photoSession.cameraPosition = (photoSession.cameraPosition == .back) ? .front : .back
        }
    }
    
    func resetZoom() {
        lastScale = 1.0
        session?.zoom = Double(lastScale)
    }
    
    func shouldDisplayFlash() -> Bool {
        if let photoSession = session as? PhotoCaptureSession {
            return photoSession.captureDeviceInput?.device.hasFlash ?? false
        }
        return false
    }
    
    func resetToAutoFocus() {
        if let photoSession = session as? PhotoCaptureSession {
            photoSession.resetDeviceConfiguration()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupView() {
        let focusTapGesture =
            UITapGestureRecognizer(target: self,
                                         action: #selector(handleFocusTap(recognizer:)))
        addGestureRecognizer(focusTapGesture)
        
        let zoomPinchGesture =
            UIPinchGestureRecognizer(target: self,
                                     action: #selector(handleZoomPinch(recognizer:)))
        addGestureRecognizer(zoomPinchGesture)
    }
    
    private func addFocusView(at point: CGPoint) {
        focusView?.removeFromSuperview()
        focusTimer?.invalidate()

        let focusView = UIImageView(frame: CGRect(origin: point, size: focusViewSize))
        focusView.center = point
        focusView.image = UIImage(named: "ic-camera-focus-marks")
        focusView.layer.masksToBounds = true

        clipsToBounds = true
        addSubview(focusView)
        self.focusView = focusView
        
        focusTimer = Timer.scheduledTimer(withTimeInterval: animationFadeFocusView,
                                          repeats: false,
                                          block: { [weak self] (timer) in
                                            timer.invalidate()
                                            guard let sSelf = self else { return }
                                            sSelf.focusView?.removeFromSuperview()
        })
    }
    
    // MARK: - GestureRecognizer
    
    @objc private func handleFocusTap(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: self)
        if let point = previewLayer?.captureDevicePointConverted(fromLayerPoint: location) {
            if session?.focus(at: point) == true {
                addFocusView(at: location)
            }
        }
    }
    
    @objc private func handleZoomPinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began {
            recognizer.scale = lastScale
        }
        let zoom = max(minZoom, min(maxZoom, recognizer.scale))
        session?.zoom = Double(zoom)
        if recognizer.state == .ended {
            lastScale = zoom
        }
    }

}
