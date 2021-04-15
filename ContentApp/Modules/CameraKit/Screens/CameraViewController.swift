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
            session.resolution = wideResolution
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
        
        configureViewsLayout()

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
    
    // MARK: - Configure Layout Methods
    
    private func configureViewsLayout() {
        let aspectRatio: CGFloat = 4 / 3
        let viewWidth = view.bounds.width
        let viewHeight = view.bounds.height
        
        topBarView.frame.size = CGSize(width: viewWidth, height: 44)
        finderView.frame.size = CGSize(width: viewWidth, height: viewWidth * aspectRatio)
        zoomView.frame.size = CGSize(width: viewWidth, height: 64)
        shutterView.frame.size = CGSize(width: viewWidth, height: 96)
        modeView.frame.size = CGSize(width: viewWidth, height: 64)
        
        let topViewHeight = topBarView.bounds.height
        let finderViewHeight = finderView.bounds.height
        let zoomViewHeight = zoomView.bounds.height
        let shutterViewHeight = shutterView.bounds.height
        let modeViewHeight = modeView.bounds.height
        
        var topViewGuide: CGFloat = 0.0
        var finderViewGuide: CGFloat = 0.0
        var zoomViewGuide: CGFloat = 0.0
        var shutterViewGuide: CGFloat = 0.0
        var modeViewGuide: CGFloat = 0.0
        
        let case1 = topViewHeight + finderViewHeight + shutterViewHeight + modeViewHeight
        let case2 = topViewHeight + finderViewHeight + modeViewHeight
        let case3 = topViewHeight + finderViewHeight
        
        if case1 <= viewHeight { // All elemets fits
            let offset = (viewHeight - (case1)) / 2
            topViewGuide = offset
            finderViewGuide = topViewGuide + topViewHeight
            shutterViewGuide = finderViewGuide + finderViewHeight
            modeViewGuide = shutterViewGuide + shutterViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        } else if case2 <= viewHeight { // All elemets except the shutter fits
            let offset = (viewHeight - (case2)) / 2
            topViewGuide = offset
            finderViewGuide = topViewGuide + topViewHeight
            shutterViewGuide = finderViewGuide + finderViewHeight - shutterViewHeight
            modeViewGuide = finderViewGuide + finderViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        } else if case3 <= viewHeight { // Only the top bar and finder fits
            let offset = (viewHeight - (case3)) / 2
            topViewGuide = offset
            finderViewGuide = topViewGuide + topViewHeight
            modeViewGuide = finderViewGuide + finderViewHeight - modeViewHeight
            shutterViewGuide = modeViewGuide - shutterViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        } else { // Overlay everything on top of the finder
            let offset = (viewHeight - finderViewHeight) / 2
            topViewGuide = offset
            finderViewGuide = offset
            modeViewGuide = finderViewGuide + finderViewHeight - modeViewHeight
            shutterViewGuide = modeViewGuide - shutterViewHeight
            zoomViewGuide = shutterViewGuide - zoomViewHeight
        }
        
        topBarView.frame = CGRect(x: 0, y: topViewGuide, width: viewWidth, height: topViewHeight)
        finderView.frame = CGRect(x: 0, y: finderViewGuide, width: viewWidth, height: finderViewHeight)
        zoomView.frame = CGRect(x: 0, y: zoomViewGuide, width: viewWidth, height: zoomViewHeight)
        shutterView.frame = CGRect(x: 0, y: shutterViewGuide, width: viewWidth, height: shutterViewHeight)
        modeView.frame = CGRect(x: 0, y: modeViewGuide, width: viewWidth, height: modeViewHeight)
        
        configureTopViewLayout()
        configureFinderViewLayout()
        configureZoomView()
        configureShutterView()
        configureModeView()
    }
    
    private func configureTopViewLayout() {
        let topBarViewHeight = topBarView.frame.height
        let flashModeButtonX = topBarView.frame.width - flashModeButton.bounds.width - 16
        
        closeButton.frame.origin = CGPoint(x: 16, y: 0)
        closeButton.center.y = topBarViewHeight / 2.0
        flashModeButton.frame.origin = CGPoint(x: flashModeButtonX, y: 0)
        flashModeButton.center.y = topBarViewHeight / 2.0
    }
    
    private func configureFinderViewLayout() {
        sessionPreview.frame.origin = .zero
        sessionPreview.frame.size = finderView.frame.size
    }
    
    private func configureZoomView() {
        zoomLabel.center = CGPoint(x: zoomView.frame.width / 2, y: zoomView.frame.height / 2)
        zoomLabel.frame.size = CGSize(width: 40, height: 40)
    }
    
    private func configureShutterView() {
        let switchCameraButtonX = shutterView.frame.width - switchCameraButton.bounds.width - 16
        
        captureButton.center = CGPoint(x: shutterView.frame.width / 2, y: shutterView.frame.height / 2)
        switchCameraButton.frame.origin.x = switchCameraButtonX
        switchCameraButton.center.y = captureButton.center.y
    }
    
    private func configureModeView() {
        cameraSlider.center = CGPoint(x: modeView.frame.width / 2, y: modeView.frame.height / 2)
        cameraSlider.translatesAutoresizingMaskIntoConstraints = true
    }
    
    // MARK: - Private Methods
    
    private func cameraSliderConfiguration() {
        guard let theme = self.theme, let localization = self.localization else { return }

        let sliderStyle = CameraSliderControlSyle(selectedOptionColor: theme.onSurfaceColor,
                                                  optionColor: theme.onSurface60Color,
                                                  optionFont: theme.subtitle2Font,
                                                  optionBackgroundColor: theme.surfaceColor)

        cameraSlider.addSlider(entries: CameraSliderEntry(entryName: localization.sliderPhoto))
        cameraSlider.updateStyle(style: sliderStyle)
        cameraSlider.delegate = self
    }
    
    private func applyComponentsThemes() {
        guard let theme = self.theme else { return }

        view.backgroundColor = theme.surfaceColor
        closeButton.tintColor = theme.onSurface60Color
        flashModeButton.tintColor = theme.onSurface60Color
        switchCameraButton.tintColor = theme.onSurface60Color
        switchCameraButton.backgroundColor = theme.surfaceColor.withAlphaComponent(0.6)
        zoomLabel.backgroundColor = theme.surfaceColor.withAlphaComponent(0.6)
        
        let image = UIImage(color: theme.surfaceColor,
                            size: navigationController?.navigationBar.bounds.size)
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = theme.surfaceColor
        navigationController?.navigationBar.tintColor = theme.onSurface60Color
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.barTintColor = theme.surfaceColor
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: theme.headline6Font,
             NSAttributedString.Key.foregroundColor: theme.onSurfaceColor]
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
