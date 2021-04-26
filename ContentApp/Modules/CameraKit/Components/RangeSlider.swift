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

struct RangeSliderControlSyle {
    let thumbTintColor: UIColor
    let tintColor: UIColor
    let optionFont: UIFont
    let fontColor: UIColor
}

protocol RangeSliderControlDelegate: class {
    func didChangeSlider(value: Float)
}

class RangeSlider: UISlider {
    weak var delegate: RangeSliderControlDelegate?
    private var shouldCallDelegate = true
    
    private var style = RangeSliderControlSyle(thumbTintColor: .white,
                                               tintColor: .white,
                                               optionFont: .systemFont(ofSize: 14),
                                               fontColor: .black)
    
    var trackWidth: CGFloat = 2 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Public interface
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setThumbImage(for: value)
    }
    
    override func setValue(_ value: Float, animated: Bool) {
        super.setValue(value, animated: animated)
        
        setThumbImage(for: value)
        if shouldCallDelegate {
            delegate?.didChangeSlider(value: value)
        } else {
            shouldCallDelegate = true
        }
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let defaultBounds = super.trackRect(forBounds: bounds)
        return CGRect(
            x: defaultBounds.origin.x,
            y: defaultBounds.origin.y + defaultBounds.size.height / 2 - trackWidth / 2,
            width: defaultBounds.size.width,
            height: trackWidth)
    }
    
    func setSlider(value: Float) {
        shouldCallDelegate = false
        setValue(value, animated: false)
    }
    
    func update(style: RangeSliderControlSyle) {
        self.style = style
        applyCurrentStyle()
    }
    
    // MARK: Private interface
    
    private func applyCurrentStyle() {
        minimumTrackTintColor = style.tintColor
        maximumTrackTintColor = style.tintColor
        thumbTintColor = style.thumbTintColor
    }
    
    private func progressImage(with progress: Float) -> UIImage {
        return autoreleasepool { () -> UIImage in
            let layer = CALayer()
            layer.backgroundColor = style.thumbTintColor.cgColor
            layer.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            layer.cornerRadius = layer.bounds.height / 2

            let label = UILabel(frame: layer.frame)
            label.font = style.optionFont
            label.textColor = style.fontColor
            
            let strProgress = String(format: "%.1f", progress)
                        
            if Float(strProgress)?.truncatingRemainder(dividingBy: 1) == 0 {
                let final = strProgress.split(separator: ".")
                label.text = String(final[0]) + "x"
            } else {
                label.text = strProgress + "x"
            }
            label.text = ""
            layer.addSublayer(label.layer)
            label.textAlignment = .center
            
            let renderer = UIGraphicsImageRenderer(bounds: layer.bounds)
            let image = renderer.image { (ctx) in
                layer.render(in: ctx.cgContext)
            }

            UIGraphicsBeginImageContext(layer.frame.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)

            UIGraphicsEndImageContext()
            
            return image
        }
    }
    
    private func setThumbImage(for value: Float) {
        setThumbImage(progressImage(with: value), for: .normal)
        setThumbImage(progressImage(with: value), for: .selected)
        setThumbImage(progressImage(with: value), for: .highlighted)
    }
}
