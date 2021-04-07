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

class CameraViewController: UIViewController {
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var flashModeButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var cameraSlider: CameraSliderControl!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var featuresView: UIView!
    @IBOutlet weak var sessionPreview: SessionPreview! {
        didSet {
            let session = PhotoCaptureSession()
            session.resolution = wideResolution
            session.delegate = cameraViewModel
            session.uiDelegate = self

            sessionPreview.add(session: session)
            sessionPreview.previewLayer?.videoGravity = .resizeAspectFill
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
        cameraViewModel.delegate = self
        cameraSliderConfiguration()

        zoomLabel.layer.cornerRadius = zoomLabel.bounds.height / 2.0
        zoomLabel.layer.masksToBounds = true
        zoomLabel.font = theme?.subtitle2Font
        switchCameraButton.layer.cornerRadius = switchCameraButton.bounds.height / 2.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        sessionPreview.startSession()
        cameraViewModel.deletePreviousCapture()
        applyComponentsThemes()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        sessionPreview.stopSession()
        sessionPreview.resetZoom()
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
        sessionPreview.capture()
    }

    @IBAction func switchCamerasButtonTapped(_ sender: UIButton) {
        sessionPreview.resetZoom()
        sessionPreview.changeCameraPosition()
    }
    
    // MARK: - Private Methods
    
    private func cameraSliderConfiguration() {
        guard let currentTheme = theme, let localization = self.localization else { return }

        let sliderStyle = CameraSliderControlSyle(selectedOptionColor: currentTheme.onSurfaceColor,
                                                  optionColor: currentTheme.onSurface60Color,
                                                  optionFont: currentTheme.subtitle2Font,
                                                  optionBackgroundColor: currentTheme.surfaceColor)

        cameraSlider.addSlider(entries: CameraSliderEntry(entryName: localization.sliderPhoto))
        cameraSlider.updateStyle(style: sliderStyle)
    }
    
    private func applyComponentsThemes() {
        guard let currentTheme = theme else { return }
        view.backgroundColor = currentTheme.surfaceColor
        featuresView.backgroundColor = currentTheme.surfaceColor
        topBarView.backgroundColor = currentTheme.surfaceColor
        closeButton.tintColor = currentTheme.onSurface60Color
        flashModeButton.tintColor = currentTheme.onSurface60Color
        switchCameraButton.tintColor = currentTheme.onSurface60Color
        switchCameraButton.backgroundColor = currentTheme.surfaceColor?.withAlphaComponent(0.6)
        zoomLabel.backgroundColor = currentTheme.surfaceColor?.withAlphaComponent(0.6)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
           let pvc = segue.destination as? PreviewViewController {
            pvc.capturedAsset = sender as? CapturedAsset
        }
    }
}

// MARK: - CameraViewModel Delegate

extension CameraViewController: CameraViewModelDelegate {
    func finishProcess(capturedAsset: CapturedAsset?, error: Error?) {
        if let capturedAsset = capturedAsset {
            performSegue(withIdentifier: SegueIdentifiers.showPreviewVCfromCameraVC.rawValue,
                         sender: capturedAsset)
        }
    }
}

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

// MARK: - Camera Storyboard Instantiable

extension CameraViewController: CameraStoryboardInstantiable { }
