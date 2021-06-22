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

import Foundation
import UIKit

enum ButtonInput {
    case photo
    case video
}

struct CameraButtonStyle {
    let photoButtonColor: UIColor
    let videoButtonColor: UIColor
    let outerRingColor: UIColor
}

class CameraButton: UIButton {
    private var pathLayer: CAShapeLayer?
    private let animationDuration = 0.2
    private let innerSmallGuide: CGFloat = 9/7.0
    private let innerBigProportion: CGFloat = 9/5.0
    
    var buttonInput = ButtonInput.photo
    private var style = CameraButtonStyle(photoButtonColor: .blue,
                                          videoButtonColor: .red,
                                          outerRingColor: .white)
    override var buttonType: UIButton.ButtonType {
        return .custom
    }
    
    override var isSelected: Bool {
        didSet {
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animationDuration
            morph.timingFunction = CAMediaTimingFunction(name: .easeIn)
            morph.toValue = currentInnerPath().cgPath
            
            if buttonInput == .video {
                morph.fillMode = .forwards
                morph.isRemovedOnCompletion = false
            }
            pathLayer?.add(morph, forKey: "")
        }
    }
    
    // MARK: - Public interface
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        addTarget(self, action: #selector(touchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(touchDown), for: .touchDown)
    }
    
    @objc func touchUpInside(sender: UIButton) {
        if buttonInput == .video {
            let colorChange = CABasicAnimation(keyPath: "fillColor")
            colorChange.duration = animationDuration
            colorChange.toValue = style.videoButtonColor
            colorChange.fillMode = .forwards
            colorChange.isRemovedOnCompletion = false
            colorChange.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            pathLayer?.add(colorChange, forKey: "darkColor")
            isSelected = !isSelected
            backgroundColor = style.outerRingColor
            
        } else {
            isSelected = true
        }
    }
    
    @objc func touchDown(sender: UIButton) {
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration
        morph.toValue = buttonInput == .video ? style.videoButtonColor : style.photoButtonColor
        
        if buttonInput == .video {
            morph.fillMode = .forwards
            morph.isRemovedOnCompletion = false
            backgroundColor = style.outerRingColor
        }
        morph.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pathLayer?.add(morph, forKey: "")
    }
     
    func update(style: CameraButtonStyle) {
        self.style = style
        setup()
    }
    
    // MARK: - Private interface
    
    private func setup() {
        backgroundColor = style.outerRingColor
        layer.cornerRadius = frame.height / 2
        
        let pathLayer = CAShapeLayer()
        pathLayer.path = currentInnerPath().cgPath
        pathLayer.strokeColor = nil
        pathLayer.fillColor = buttonInput == .photo ? style.photoButtonColor.cgColor : style.videoButtonColor.cgColor
        layer.addSublayer(pathLayer)
        self.pathLayer = pathLayer
        tintColor = .clear
    }
    
    private func currentInnerPath() -> UIBezierPath {
        return (isSelected) ? innerSmallPath() : innerBigPath()
    }
    
    private func innerBigPath() -> UIBezierPath {
        let lenght = bounds.width / innerSmallGuide
        let size = CGSize(width: lenght, height: lenght)
        let center = (bounds.width - lenght) / 2
        let point = CGPoint(x: center, y: center)
        let cornerRadius = lenght / 2
        return UIBezierPath(roundedRect: CGRect(origin: point, size: size),
                            cornerRadius: cornerRadius)
    }
    
    private func innerSmallPath() -> UIBezierPath {
        let lenght = bounds.width / innerBigProportion
        let size = CGSize(width: lenght, height: lenght)
        let center = (bounds.width - lenght) / 2
        let point = CGPoint(x: center, y: center)
        let cornerRadius = buttonInput == .video ? 4 : lenght / 2
        return UIBezierPath(roundedRect: CGRect(origin: point, size: size),
                            cornerRadius: cornerRadius)
    }
}
