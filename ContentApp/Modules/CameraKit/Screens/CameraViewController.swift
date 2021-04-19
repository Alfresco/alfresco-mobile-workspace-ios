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

class CameraViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var zoomLabel: UILabel!
    
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var finderView: UIView!
    @IBOutlet weak var zoomView: UIView!
    @IBOutlet weak var shutterView: UIView!
    @IBOutlet weak var modeView: UIView!

    @IBOutlet weak var cameraSlider: CameraSliderControl!
    @IBOutlet weak var sessionPreview: SessionPreview! {
        didSet {
            let session = PhotoCaptureSession()
            session.aspectRatio = .ar4per3
            session.delegate = cameraViewModel
            session.uiDelegate = self

            sessionPreview.add(session: session)
            sessionPreview.previewLayer?.videoGravity = .resizeAspectFill

            flashModeButton.isHidden = !sessionPreview.shouldDisplayFlash()
        }
    }
    
    var cameraViewModel = CameraViewModel()
    var theme: CameraConfigurationLayout?
    var localization: CameraLocalization?

    var uiOrientation: UIImage.Orientation = UIDevice.current.orientation.imageOrientation
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewsLayout(for: view.bounds.size)
        cameraViewModel.delegate = self
        cameraSliderConfiguration()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        sessionPreview.startSession()
        cameraViewModel.deletePreviousCapture()
        applyComponentsThemes()
        cameraSlider.setNeedsLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        sessionPreview.stopSession()
        sessionPreview.resetZoom()
        sessionPreview.resetToAutoFocus()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        configureViewsLayout(for: size)
        sessionPreview.updateAspectRatioResolution()
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        sessionPreview.stopSession()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flashModeButtonTapped(_ sender: UIButton) {
        sessionPreview.nextFlashMode()
        flashModeButton.setImage(sessionPreview.flashModeIcon(), for: .normal)
    }
    
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        captureButton.isUserInteractionEnabled = false
        sessionPreview.capture()
    }

    @IBAction func switchCamerasButtonTapped(_ sender: UIButton) {
        sessionPreview.resetZoom()
        sessionPreview.changeCameraPosition()
        flashModeButton.isHidden = !sessionPreview.shouldDisplayFlash()
    }
    
    // MARK: - Private Methods
    
    private func cameraSliderConfiguration() {
        guard let theme = self.theme, let localization = self.localization else { return }

        let sliderStyle = CameraSliderControlSyle(selectedOptionColor: theme.onSurfaceColor,
                                                  optionColor: theme.onSurface60Color,
                                                  optionFont: theme.subtitle2Font,
                                                  optionBackgroundColor: theme.surface60Color)

        cameraSlider.addSlider(entries: CameraSliderEntry(entryName: localization.sliderPhoto))
        cameraSlider.updateStyle(style: sliderStyle)
        cameraSlider.delegate = self
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
           let pvc = segue.destination as? PreviewViewController {
            let previewViewModel = PreviewViewModel(capturedAsset: cameraViewModel.capturedAsset)
            pvc.previewViewModel = previewViewModel
            pvc.theme = theme
            pvc.localization = localization
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
    func didChange(zoom: Double) {
        var text = String(format: "%.1f", zoom)
        guard let aprox = Double(text) else { return }

        if aprox - Double(Int(aprox)) == 0.0 {
            text = "\(Int(aprox))"
        }
        zoomLabel.text = "\(text)x"
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
        }
    }
}

// MARK: - CameraSliderControl Delegate

extension CameraViewController: CameraSliderControlDelegate {
    func didChangeSelection(to currentSelection: Int) {
    }
}

// MARK: - Camera Storyboard Instantiable

extension CameraViewController: CameraStoryboardInstantiable { }
