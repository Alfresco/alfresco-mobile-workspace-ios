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
import SwiftUI

let animationRotateCameraButtons = 0.5
let animationFadeView = 0.2
let photoSlider = 0
let videoSlider = 1

class CameraViewController: UIViewController {
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var shutterButton: ShutterButton!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var zoomSlider: RangeSlider!

    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var flashMenuView: FlashMenu!
    @IBOutlet weak var finderView: UIView!
    @IBOutlet weak var zoomView: UIView!
    @IBOutlet weak var shutterView: UIView!
    @IBOutlet weak var modeView: UIView!
    
    @IBOutlet weak var modeSelector: ModeSelectorControl!
    @IBOutlet weak var sessionPreview: SessionPreview!
    var timerView: UIView?
    var currentCameraMode: Int = 0 // 0 camera, 1 video
    
    var cameraViewModel: CameraViewModel?
    weak var cameraDelegate: CameraKitCaptureDelegate?
    var uiOrientation: UIImage.Orientation = UIDevice.current.orientation.imageOrientation

    private var zoomSliderTimer: Timer?
    private var cameraSession: CaptureSession?
    private var timerViewConfig: TimerViewConfig?
    
    // --- multi photos view ---
    @IBOutlet weak var multiPhotosView: UIView!
    @IBOutlet weak var multiPhotosImageView: UIImageView!
    @IBOutlet weak var multiPhotosNumberIndicatorView: UIView!
    @IBOutlet weak var multiPhotosNumberLabel: UILabel!
    @IBOutlet weak var multiPhotosButton: UIButton!
 
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateMultiPhotosViewUI()
        ApplicationBootstrap.shared().configureCameraKitTheme()
        cameraViewModel?.delegate = self
        configureViewsLayout(for: view.bounds.size)
        setUpShutterButton()
        setUpFlashMenu()
        setUpZoomSlider()
        setUpModeSelector()
        setUpTimerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        self.perform(#selector(sessionStart), with: nil, afterDelay: 0.1)
        applyComponentsThemes()
        zoomSlider.setSlider(value: sessionPreview.zoom)
        modeSelector.setNeedsLayout()
    }
    
    @objc private func sessionStart() {
        sessionPreview.startSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !ConfigurationManager.shared.isEnterpriseUser() {
            cameraViewModel?.deletePreviousCapture()
        }
        if cameraSession != nil {
            sessionPreview.update(flashMode: flashMenuView.flashMode)
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
    }

    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        guard let numberOfCapturedAssets = cameraViewModel?.capturedAssets.count,
              numberOfCapturedAssets != 0 else {
            dismissCamera()
            return
        }
        CameraKit.shouldDiscard(numberOfCapturedAssets: numberOfCapturedAssets,
                                in: self) { [weak self] discarded in
            guard let sSelf = self else { return }
            if discarded {
                sSelf.dismissCamera()
            }
        }
    }
    
    @IBAction func flashModeButtonTapped(_ sender: UIButton) {
        apply(fade: (flashMenuView.alpha == 1.0), to: flashMenuView)
    }
    
    @IBAction func captureButtonTapped(_ sender: ShutterButton) {
        if modeSelector.currentSelection == photoSlider {
            shutterButton.isUserInteractionEnabled = false
        } else if modeSelector.currentSelection == videoSlider {
            timerViewConfig?.isStarted = !(timerViewConfig?.isStarted ?? true)
            timerView?.isHidden = !(timerView?.isHidden ?? true)
            modeSelector.isHidden = !modeSelector.isHidden
            switchCameraButton.isHidden = !switchCameraButton.isHidden
        }
        sessionPreview.capture()
        apply(fade: true, to: flashMenuView)
    }
    
    @IBAction func multiPhotosButtonTapped(_ sender: UIButton) {
        if cameraViewModel?.capturedAssets.isEmpty == false {
            performSegue(withIdentifier: SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
                         sender: nil)
        }
    }
    
    @IBAction func switchCamerasButtonTapped(_ sender: UIButton) {
        sessionPreview.changeCameraPosition()
        setUpCameraSession(for: modeSelector.currentSelection)
        
        flashModeButton.setImage(FlashMode.auto.icon, for: .normal)
        flashModeButton.isHidden = !sessionPreview.shouldDisplayFlash()

        sessionPreview.reset(settings: [.flash, .focus, .zoom])
        
        apply(fade: true, to: flashMenuView)

        shutterButton.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let sSelf = self else { return }
            sSelf.shutterButton.isUserInteractionEnabled = true
        }
    }
    
    // MARK: - Private Methods
    
    private func dismissCamera() {
        sessionPreview.stopSession()
        cameraDelegate?.didEndReview(for: [])
        cameraViewModel?.deleteAllCapturedAssets()
        dismiss(animated: true, completion: nil)
    }

    private func setUpShutterButton() {
        guard let theme = CameraKit.theme else { return }
        
        let style = ShutterButtonStyle(photoButtonColor: theme.photoShutterColor,
                                      videoButtonColor: theme.videoShutterColor,
                                      outerRingColor: theme.surface60Color)
        shutterButton.buttonInput = (modeSelector.currentSelection == photoSlider) ? .photo : .video
        shutterButton.update(style: style)
    }
    
    private func setUpCameraSession(for slider: Int) {
        setUpShutterButton()

        var session: CaptureSession
        
        if slider == photoSlider {
            session = PhotoCaptureSession(position: sessionPreview.cameraPosition)
        } else {
            session = VideoCaptureSession(position: sessionPreview.cameraPosition)
        }

        session.delegate = cameraViewModel
        session.uiDelegate = self
        session.mediaFilesFolderPath = cameraViewModel?.folderToSavePath
        sessionPreview.add(session: session)
        sessionPreview.previewLayer?.videoGravity = .resizeAspectFill

        flashModeButton.isHidden = !sessionPreview.shouldDisplayFlash()

        cameraSession = session
        
        configureViewsLayout(for: view.bounds.size)
    }
    
    private func setUpModeSelector() {
        guard let theme = CameraKit.theme, let localization = CameraKit.localization else { return }

        let style = ModeSelectorControlSyle(selectedOptionColor: theme.onSurfaceColor,
                                            optionColor: theme.onSurface60Color,
                                            optionFont: theme.subtitle2Font,
                                            optionBackgroundColor: theme.surface60Color)
        
        modeSelector.addSlider(entries: ModeSelectorEntry(entryName: localization.photoMode),
                               ModeSelectorEntry(entryName: localization.videoMode))
        modeSelector.update(style: style)
        modeSelector.delegate = self
    }

    private func setUpTimerView() {
        guard let theme = CameraKit.theme else { return }

        let config = TimerViewConfig()
        config.font = theme.subtitle2Font
        config.fontColor = theme.onSurfaceColor
        config.roundedBorderColor = theme.surface60Color
        timerViewConfig = config

        let timer = TimerView(config: config)
        let hostingController = UIHostingController(rootView: timer)
        if let hostView = hostingController.view {
            hostView.backgroundColor = .clear
            hostView.frame = CGRect(x: .zero,
                                    y: .zero,
                                    width: config.borderWidth,
                                    height: config.borderHeight)
            modeView.addSubview(hostView)
            hostView.isHidden = true
            timerView = hostView
        }
    }
    
    private func setUpZoomSlider() {
        guard let theme = CameraKit.theme else { return }

        let surfaceColor = UIColor(hex: "#FFFFFF")
        let surface60Color = UIColor(hex: "#FFFFFF", alpha: 0.6)

        let style = RangeSliderControlSyle(thumbTintColor: surfaceColor,
                                           tintColor: surface60Color,
                                           optionFont: theme.subtitle2Font,
                                           fontColor: theme.onSurfaceColor)
        zoomSlider.update(style: style)
        zoomSlider.delegate = self
        zoomSlider.minimumValue = minZoom
        zoomSlider.maximumValue = maxZoom
        zoomSlider.alpha = 0.0
        zoomLabel.isHidden = true
    }
    
    private func setUpFlashMenu() {
        guard let theme = CameraKit.theme,
              let localization = CameraKit.localization else { return }
        
        let style = FlashMenuStyle(optionTintColor: theme.onSurface60Color,
                                   optionFont: theme.subtitle2Font,
                                   optionColor: theme.onSurfaceColor,
                                   backgroundColor: theme.surface60Color,
                                   autoFlashText: localization.autoFlashText,
                                   onFlashText: localization.onFlashText,
                                   offFlashText: localization.offFlashText)
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
           let assets = cameraViewModel?.capturedAssets {
            let previewViewModel = PreviewViewModel(assets: assets)
            pvc.controller.previewViewModel = previewViewModel
            pvc.cameraDelegate = cameraDelegate
            previewViewModel.callback = { (deletedIndex) in
                self.cameraViewModel?.capturedAssets.remove(at: deletedIndex)
                self.updateMultiPhotosViewUI()
            }
        }
    }
}

// MARK: - CameraViewModel Delegate

extension CameraViewController: CameraViewModelDelegate {
    func deleteAllCapturedAssets() {
        updateMultiPhotosViewUI()
    }
    
    func finishProcess(capturedAsset: CapturedAsset?, error: Error?) {
        shutterButton.isUserInteractionEnabled = true
        guard error == nil else { return }
        
        if !ConfigurationManager.shared.isEnterpriseUser() {
            multiPhotosView.isHidden = true
            performSegue(withIdentifier: SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
                                     sender: nil)
        } else {
            updateMultiPhotosViewUI()
        }
    }
    
    private func updateMultiPhotosViewUI() {
        if cameraViewModel?.capturedAssets.isEmpty == true || !ConfigurationManager.shared.isEnterpriseUser() {
            multiPhotosView.isHidden = true
        } else {
            let capturedAssetsCount = cameraViewModel?.capturedAssets.count ?? 0
            let image = cameraViewModel?.capturedAssets.last?.thumbnailImage()
            multiPhotosNumberLabel.text = String(capturedAssetsCount)
            multiPhotosView.isHidden = false
            multiPhotosImageView.image = image
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
            sSelf.multiPhotosView.rotate(to: orientation)
        }
    }
}

// MARK: - ModeSelectorControl Delegate

extension CameraViewController: ModeSelectorControlDelegate {
    func didChangeSelection(to currentSelection: Int) {
        sessionPreview.reset(settings: [.flash, .focus, .position, .zoom])
        flashMenuView.flashMode = .auto
        flashModeButton.setImage(FlashMode.auto.icon, for: .normal)
        setUpCameraSession(for: currentSelection)
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
