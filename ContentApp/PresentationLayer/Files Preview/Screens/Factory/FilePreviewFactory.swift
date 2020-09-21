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

    static func getPlainTextPreview(with text: String, on size: CGSize) -> FilePreviewProtocol {
        let plainTextPreview = PlainTextPreview()
        plainTextPreview.display(text: text)
        return plainTextPreview
    }

    static func getPreview(for previewType: FilePreviewType, and url: URL? = nil, on size: CGSize,
                           completion: ((_ done: Bool, _ error: Error?) -> Void)? = nil) -> FilePreviewProtocol {
        guard let url = url else {
            completion?(true, nil)
            return FileWithoutPreview()
        }
        switch previewType {
        case .image, .svg, .gif:
            let imagePreview = ImagePreview(frame: CGRect(origin: .zero, size: size))
            imagePreview.display(for: previewType, from: url) { (_, completed, total, error) in
                if let error = error {
                    completion?(true, error)
                    AlfrescoLog.error(error)
                }
                completion?(completed == total, nil)
            }
            return imagePreview
        case .pdf, .rendition:
            let pdfRendered = PDFRenderer(with: CGRect(origin: .zero, size: size), pdfURL: url)
            completion?(true, nil)
            return pdfRendered
        case .video, .audio:
            if let mediaPreview: MediaPreview = .fromNib() {
                mediaPreview.frame = CGRect(origin: .zero, size: size)
                mediaPreview.play(from: url, isAudioFile: (previewType == .audio))
                completion?(true, nil)
                return mediaPreview
            }
            completion?(true, nil)
            return FileWithoutPreview()
        default:
            completion?(true, nil)
            return FileWithoutPreview()
        }
    }
}
