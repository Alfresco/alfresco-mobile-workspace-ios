//
// Copyright (C) 2005-2020 Alfresco Software Limited.
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

extension UIView {
    func dropShadow(opacity: Float, radius: Float) {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }

    func dropContourShadow(opacity: Float, radius: Float, xOffset: Float = 0, yOffset: Float = 0) -> CALayer {
        let xOffset = CGFloat(xOffset)
        let yOffset = CGFloat(yOffset)
        let shadowOffset = CGSize(width: xOffset, height: yOffset)
        let shadowOpacity = opacity
        let shadowRadius = CGFloat(radius)
        let shadowPath = UIBezierPath(rect: self.frame).cgPath
        let shadowColor = UIColor.black

        let shadowLayer = CALayer()
        let mutablePath = CGMutablePath()
        let maskLayer = CAShapeLayer()

        let shadowFrame = self.frame.insetBy(dx: -2 * shadowRadius, dy: -2 * shadowRadius).offsetBy(dx: xOffset, dy: yOffset)
        let shadowRect = CGRect(origin: .zero, size: shadowFrame.size)
        let shadowTransform = CGAffineTransform(translationX: -self.frame.origin.x - xOffset + 2 * shadowRadius, y: -self.frame.origin.y - yOffset + 2 * shadowRadius)

        shadowLayer.shadowOffset = shadowOffset
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowRadius
        shadowLayer.shadowPath = shadowPath
        shadowLayer.shadowColor = shadowColor.cgColor

        mutablePath.addRect(shadowRect)
        mutablePath.addPath(shadowLayer.shadowPath!, transform: shadowTransform)
        mutablePath.closeSubpath()

        maskLayer.frame = shadowFrame
        maskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        maskLayer.path = mutablePath
        shadowLayer.mask = maskLayer

        self.layer.superlayer?.insertSublayer(shadowLayer, above: self.layer)

        return shadowLayer
    }

    func applyCornerRadius(with radius: Float, mask: CACornerMask = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]) {
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.masksToBounds = true
        self.layer.maskedCorners = mask
    }
}
