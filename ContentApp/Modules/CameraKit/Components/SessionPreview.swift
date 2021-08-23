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

let focusViewSize = CGSize(width: 72, height: 72)
let minZoom: Float = 1.0
let maxZoom: Float = 10.0
let animationFadeFocusView = 2.0

enum CameraSettings {
    case flash
    case focus
    case position
    case mode
    case zoom
}

class SessionPreview: UIView {
    private var focusView: UIImageView?
    private var lastScale = minZoom
    private var focusTimer: Timer?
    var isVideoRecording: Bool? = false
    
    private(set) var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let previewLayer = previewLayer {
                layer.addSublayer(previewLayer)
            }
        }
    }

    var cameraPosition: CameraPosition = .back
    
    var zoom: Float = 1.0 {
        didSet {
            lastScale = zoom
            session?.zoom = lastScale
        }
    }
    
    private var session: CaptureSession? {
        didSet {
            oldValue?.stop()
            if let session = session {
                previewLayer = AVCaptureVideoPreviewLayer(session: session.session)
                session.previewLayer = previewLayer
                session.overlayView = self
                if let photoSession = session as? PhotoCaptureSession {
                    zoom = photoSession.naturalZoomFactor
                }
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
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.cameraOrientation
        } else {
            previewLayer?.connection?.videoOrientation = .portrait
        }
    }
    
    // MARK: - Public Methods
    
    func add(session: CaptureSession) {
        stopSession()

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
    
    func update(flashMode: FlashMode) {
        session?.flashMode = flashMode
    }
    
    func shouldDisplayFlash() -> Bool {
        return session?.shouldDisplayFlashMode() ?? false
    }
    
    func reset(settings: [CameraSettings]) {
        for setting in settings {
            switch setting {
            case .flash:
                session?.flashMode = .auto
            case .zoom:
                zoom = session?.naturalZoomFactor ?? 1
            case .focus:
                session?.resetDeviceConfiguration()
            case .position:
                session?.cameraPosition = .back
            case .mode:
                break
            }
        }
    }
    
    func changeCameraPosition() {
        cameraPosition = cameraPosition == .back ? .front : .back
    }

    func aspectRatio() -> CameraAspectRatio {
        return session?.aspectRatio ?? .ar4by3
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
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didRotate),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc private func didRotate() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.cameraOrientation
        } else {
            previewLayer?.connection?.videoOrientation = .portrait
        }
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
            recognizer.scale = CGFloat(lastScale)
        }
        let zoom = max(minZoom, min(maxZoom, Float(recognizer.scale)))
        session?.zoom = Float(zoom)
        if recognizer.state == .ended {
            lastScale = zoom
        }
    }
}
