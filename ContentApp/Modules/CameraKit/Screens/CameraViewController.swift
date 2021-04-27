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

import UIKit

let animationRotateCameraButtons = 0.5
let animationFadeView = 0.2

class CameraViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var captureButton: CameraButton!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var zoomSlider: RangeSlider!
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var flashMenuView: FlashMenu!
    @IBOutlet weak var finderView: UIView!
    @IBOutlet weak var zoomView: UIView!
    @IBOutlet weak var shutterView: UIView!
    @IBOutlet weak var modeView: UIView!

    @IBOutlet weak var cameraSlider: CameraSliderControl!
    @IBOutlet weak var sessionPreview: SessionPreview!
    
    private var zoomSliderTimer: Timer?
    var cameraViewModel: CameraViewModel?
    var theme: CameraConfigurationLayout?
    var localization: CameraLocalization?
    weak var cameraDelegate: CameraKitCaptureDelegate?

    var uiOrientation: UIImage.Orientation = UIDevice.current.orientation.imageOrientation

    private var cameraSession: PhotoCaptureSession?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewsLayout(for: view.bounds.size)
        cameraViewModel?.delegate = self

        cameraButtonConfiguration()
        flashModeConfiguration()
        setUpZoomSlider()
        setUpModeSelector()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        sessionPreview.startSession()
        applyComponentsThemes()
        cameraSlider.setNeedsLayout()
        zoomSlider.setSlider(value: sessionPreview.zoom)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraViewModel?.deletePreviousCapture()
        if cameraSession == nil {
            setUpCameraSession()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        sessionPreview.stopSession()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        configureViewsLayout(for: size)
        sessionPreview.updateAspectRatioResolution()
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        sessionPreview.stopSession()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flashModeButtonTapped(_ sender: UIButton) {
        apply(fade: (flashMenuView.alpha == 1.0), to: flashMenuView)
    }
    
    @IBAction func captureButtonTapped(_ sender: CameraButton) {
        captureButton.isUserInteractionEnabled = false
        sessionPreview.capture()
        apply(fade: true, to: flashMenuView)
    }

    @IBAction func switchCamerasButtonTapped(_ sender: UIButton) {
        flashModeButton.setImage(FlashMode.auto.icon, for: .normal)
        flashModeButton.isHidden = !sessionPreview.shouldDisplayFlash()
        sessionPreview.changeCameraPosition()
        sessionPreview.reset(settings: [.flash, .focus, .zoom, .mode])
        apply(fade: true, to: flashMenuView)
    }
    
    // MARK: - Private Methods

    private func cameraButtonConfiguration() {
        guard let theme = self.theme else { return }
        
        let style = CameraButtonStyle(photoButtonColor: theme.photoShutterColor,
                                      videoButtonColor: theme.videoShutterColor,
                                      outerRingColor: theme.surface60Color)
        captureButton.buttonInput = .photo
        captureButton.update(style: style)
    }
    
    private func setUpCameraSession() {
        let session = PhotoCaptureSession()
        session.aspectRatio = .ar4by3
        session.delegate = cameraViewModel
        session.uiDelegate = self
        session.mediaFilesFolderPath = cameraViewModel?.mediaFilesFolderPath
        sessionPreview.add(session: session)
        sessionPreview.previewLayer?.videoGravity = .resizeAspectFill

        flashModeButton.isHidden = !sessionPreview.shouldDisplayFlash()
        cameraSession = session
    }
    
    private func setUpModeSelector() {
        guard let theme = self.theme, let localization = self.localization else { return }
        
        let style = CameraSliderControlSyle(selectedOptionColor: theme.onSurfaceColor,
                                            optionColor: theme.onSurface60Color,
                                            optionFont: theme.subtitle2Font,
                                            optionBackgroundColor: theme.surface60Color)
        
        cameraSlider.addSlider(entries: CameraSliderEntry(entryName: localization.sliderPhoto))
        cameraSlider.update(style: style)
        cameraSlider.delegate = self
    }
    
    private func setUpZoomSlider() {
        guard let theme = self.theme else { return }

        let style = RangeSliderControlSyle(thumbTintColor: theme.surfaceColor,
                                           tintColor: theme.surface60Color,
                                           optionFont: theme.subtitle2Font,
                                           fontColor: theme.onSurfaceColor)
        zoomSlider.update(style: style)
        zoomSlider.delegate = self
        zoomSlider.minimumValue = minZoom
        zoomSlider.maximumValue = maxZoom
        zoomSlider.alpha = 0.0
        zoomLabel.isHidden = true
    }
    
    private func flashModeConfiguration() {
        guard let theme = self.theme else { return }
        
        let style = FlashMenuStyle(optionTintColor: theme.onSurface60Color,
                                   optionFont: theme.subtitle2Font,
                                   optionColor: theme.onSurfaceColor,
                                   backgroundColor: theme.surface60Color,
                                   autoFlashText: theme.autoFlashText,
                                   onFlashText: theme.onFlashText,
                                   offFlashText: theme.offFlashText)
        flashMenuView.update(style: style)
        flashMenuView.delegate = self
        flashMenuView.alpha = 0.0
    }
    
    private func apply(fade: Bool, to object: UIView) {
        let fadeTo: CGFloat = (fade) ? 0.0 : 1.0
        UIView.animate(withDuration: animationFadeView) {
            object.alpha = fadeTo
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
           let pvc = segue.destination as? PreviewViewController,
           let asset = cameraViewModel?.capturedAsset {
            let previewViewModel = PreviewViewModel(capturedAsset: asset)
            pvc.previewViewModel = previewViewModel
            pvc.theme = theme
            pvc.localization = localization
            pvc.cameraDelegate = cameraDelegate
        }
    }
}

// MARK: - CameraViewModel Delegate

extension CameraViewController: CameraViewModelDelegate {
    func finishProcess(capturedAsset: CapturedAsset?, error: Error?) {
        captureButton.isUserInteractionEnabled = true
        if capturedAsset != nil {
            performSegue(withIdentifier: SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
                         sender: nil)
        }
    }
}

// MARK: - CaptureSessionUI Delegate

extension CameraViewController: CaptureSessionUIDelegate {
    func didChange(zoom: Float) {
        var text = String(format: "%.1f", zoom)
        guard let aprox = Double(text) else { return }

        if aprox - Double(Int(aprox)) == 0.0 {
            text = "\(Int(aprox))"
        }

        zoomLabel.text = "\(text)x"
        apply(fade: true, to: zoomLabel)

        zoomSlider.setSlider(value: zoom)

        guard zoom != 1.0 else {return }
        apply(fade: false, to: zoomSlider)
        
        zoomSliderTimer?.invalidate()
        zoomSliderTimer = Timer.scheduledTimer(withTimeInterval: animationFadeFocusView,
                                          repeats: false,
                                          block: { [weak self] (timer) in
                                            timer.invalidate()
                                            guard let sSelf = self else { return }
                                            sSelf.apply(fade: true, to: sSelf.zoomSlider)
                                            sSelf.apply(fade: false, to: sSelf.zoomLabel)
        })
        
        apply(fade: true, to: flashMenuView)
    }
    
    func didChange(orientation: UIImage.Orientation) {
        guard UIDevice.current.userInterfaceIdiom != .pad else { return }
        uiOrientation = orientation
        UIView.animate(withDuration: animationRotateCameraButtons) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.closeButton.rotate(to: orientation)
            sSelf.flashModeButton.rotate(to: orientation)
            sSelf.switchCameraButton.rotate(to: orientation)
            sSelf.zoomLabel.rotate(to: orientation)
            sSelf.flashMenuView.rotate(to: orientation)
        }
    }
}

// MARK: - CameraSliderControl Delegate

extension CameraViewController: CameraSliderControlDelegate {
    func didChangeSelection(to currentSelection: Int) {
        if currentSelection == 0 && sessionPreview.cameraMode == .photo {
            // no need to reset
            return
        }
        sessionPreview.reset(settings: [.flash, .focus, .position, .zoom])
        flashModeButton.setImage(FlashMode.auto.icon, for: .normal)
    }
}

// MARK: - RangeSliderControl Delegate

extension CameraViewController: RangeSliderControlDelegate {
    func didChangeSlider(value: Float) {
        sessionPreview.zoom = value 
    }
}

// MARK: - FlashMenu Delegate

extension CameraViewController: FlashMenuDelegate {
    func selected(flashMode: FlashMode) {
        sessionPreview.update(flashMode: flashMode)
        apply(fade: true, to: flashMenuView)
        flashModeButton.setImage(flashMode.icon, for: .normal)
    }
}

// MARK: - Storyboard Instantiable

extension CameraViewController: CameraStoryboardInstantiable { }
