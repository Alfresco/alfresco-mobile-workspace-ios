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

extension UIView {
    func rotate(to orientation: UIImage.Orientation) {
        var angle: CGFloat = 0.0
        switch orientation {
        case .down, .downMirrored:
            angle = 90 * .pi/180
        case .left, .leftMirrored:
            angle = 180 * .pi/180
        case .up, .upMirrored:
            angle = 270 * .pi/180
        case .right, .rightMirrored:
            angle = 0 * .pi/180
        @unknown default:
            angle = 0 * .pi/180
        }
        self.transform = CGAffineTransform(rotationAngle: angle)
    }
}
