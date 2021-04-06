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

class CameraUtils: NSObject {
    
    static func cropAndScale(_ image: UIImage,
                             width: Int,
                             height: Int,
                             orientation: UIDeviceOrientation,
                             mirrored: Bool) -> UIImage? {
        let fromRect = CGRect(x: 0, y: 0, width: image.size.height, height: image.size.width)
        var toRect = CGRect(x: 0, y: 0, width: height, height: width)
        
        let fromAspectRatio = fromRect.width / fromRect.height
        let toAspectRatio = toRect.width / toRect.height
        
        if fromAspectRatio < toAspectRatio {
            toRect.size.width = fromRect.width
            toRect.size.height = fromRect.width / toAspectRatio
            toRect.origin.y = (fromRect.height - toRect.height) / 2.0
        } else {
            toRect.size.height = fromRect.height
            toRect.size.width = fromRect.height * toAspectRatio
            toRect.origin.x = (fromRect.width - toRect.width) / 2.0
        }
        
        guard let croppedCgImage = image.cgImage?.cropping(to: toRect) else { return nil }

        guard let colorSpace = croppedCgImage.colorSpace else { return nil }

        guard let context = CGContext(data: nil,
                                      width: height,
                                      height: width,
                                      bitsPerComponent: croppedCgImage.bitsPerComponent,
                                      bytesPerRow: height * croppedCgImage.bitsPerPixel,
                                      space: colorSpace,
                                      bitmapInfo: croppedCgImage.alphaInfo.rawValue)
        else { return nil }
        
        context.interpolationQuality = .high
        context.draw(croppedCgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
        
        guard let finalCgImage = context.makeImage() else { return nil }

        let orientation = mirrored
            ? orientation.imageOrientationMirrored
            : orientation.imageOrientation
        return UIImage(cgImage: finalCgImage, scale: 1.0, orientation: orientation)
    }
}
