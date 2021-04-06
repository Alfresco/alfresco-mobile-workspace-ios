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
    @IBOutlet weak var toolbarView: UIToolbar!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var flashModeButton: UIBarButtonItem!
    
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var featuresView: UIView!
    @IBOutlet weak var sessionPreview: SessionPreview! {
        didSet {
            let session = PhotoCaptureSession()
            session.resolution = CGSize(width: 3024, height: 4032)
            session.delegate = cameraViewModel

            sessionPreview.add(session: session)
            sessionPreview.previewLayer?.videoGravity = .resizeAspectFill
        }
    }
    
    var cameraViewModel: CameraViewModel?
    var theme: CameraConfigurationLayout?
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraViewModel?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        sessionPreview.startSession()
        cameraViewModel?.deletePreviousCapture()
        applyComponentsThemes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        sessionPreview.stopSession()
        sessionPreview.resetZoom()
    }
    
    // MARK: - IBActions
    
    @IBAction func closeButtonTapped(_ sender: UIBarButtonItem) {
        sessionPreview.stopSession()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func flashModeButtonTapped(_ sender: UIBarButtonItem) {
        sessionPreview.nextFlashMode()
        flashModeButton.image = sessionPreview.flashModeIcon()
    }
    
    @IBAction func captureButtonTapped(_ sender: UIButton) {
        sessionPreview.capture()
    }

    @IBAction func switchCamerasButtonTapped(_ sender: UIButton) {
        sessionPreview.changeCameraPosition()
    }
    
    // MARK: - Private Methods
    
    private func applyComponentsThemes() {
        guard let currentTheme = theme else { return }
        view.backgroundColor = currentTheme.surfaceColor
        featuresView.backgroundColor = currentTheme.surfaceColor
        toolbarView.barTintColor = currentTheme.surfaceColor
        toolbarView.tintColor = currentTheme.onSurface60Color
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
    
    func update(zoom: Double) {
        zoomLabel.text = String(format: "%.1fx", zoom)
    }
}

// MARK: - Camera Storyboard Instantiable

extension CameraViewController: CameraStoryboardInstantiable { }
