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

import Foundation
import UIKit

class FilePreviewFactory {
    static func getPreview(for previewType: FilePreviewType, and url: URL, on size: CGSize,
                           completion: @escaping(_ done: Bool, _ error: Error?) -> Void) -> FilePreviewProtocol? {
        switch previewType {
        case .image:
            let imagePreview = ImagePreview(frame: CGRect(origin: .zero, size: size))
            imagePreview.displayImage(from: url) { (_, completed, total, error) in
                if let error = error {
                    completion(true, error)
                    AlfrescoLog.error(error)
                }
                completion(completed == total, nil)
            }
            return imagePreview
        case .gif:
            let gifPreview = GIFPreview(frame: CGRect(origin: .zero, size: size))
            gifPreview.displayGIF(from: url) { (_, error) in
                if let error = error {
                    completion(true, error)
                }
                completion(true, error)
            }
            return gifPreview
        case .pdf, .renditionPdf:
            let pdfRendered = PDFRenderer(with: CGRect(x: 0, y: 0, width: size.width, height: size.height), pdfURL: url)
            completion(true, nil)
            return pdfRendered
        case .video, .audio:
            if let mediaPreview: MediaPreview = .fromNib() {
                mediaPreview.frame = CGRect(origin: .zero, size: size)
                mediaPreview.play(from: url, isAudioFile: (previewType == .audio))
                completion(true, nil)
                return mediaPreview
            }
            completion(true, nil)
            return nil
        default:
            completion(true, nil)
            return getNoPreview(size: size)
        }
    }

    private static func getNoPreview(size: CGSize) -> FilePreviewProtocol {
        let fileWithoutPreview = FileWithoutPreview(frame: CGRect(origin: .zero, size: size))
        if let themingService = ApplicationBootstrap.shared().serviceRepository.service(of: MaterialDesignThemingService.serviceIdentifier) as? MaterialDesignThemingService {
            fileWithoutPreview.applyComponentsThemes(themingService: themingService)
        }
        return fileWithoutPreview
    }
}
