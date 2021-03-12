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

    static func getPlainTextPreview(with text: Data, on size: CGSize) -> FilePreviewProtocol {
        let plainTextPreview = PlainTextPreview()
        plainTextPreview.display(text: text)
        return plainTextPreview
    }

    static func getPreview(for previewType: FilePreviewType,
                           node: ListNode?,
                           url: URL? = nil,
                           size: CGSize,
                           completion: ((_ error: Error?) -> Void)? = nil) -> FilePreviewProtocol {
        guard let url = url else {
            completion?(nil)
            return FileWithoutPreview(with: node)
        }

        switch previewType {
        case .image, .svg, .gif:
            let imagePreview = ImagePreview(frame: CGRect(origin: .zero, size: size))
            imagePreview.display(for: previewType, from: url) { (_, error) in
                if let error = error {
                    AlfrescoLog.error(error)
                }
                completion?(error)
            }
            return imagePreview

        case .pdf, .rendition:
            let pdfRendered = PDFRenderer(with: CGRect(origin: .zero, size: size), pdfURL: url)
            completion?(nil)
            return pdfRendered

        case .video, .audio:
            if let mediaPreview: MediaPreview = .fromNib() {
                mediaPreview.frame = CGRect(origin: .zero, size: size)
                mediaPreview.play(from: url, isAudioFile: (previewType == .audio)) { (error) in
                    completion?(error)
                }
                return mediaPreview
            }
            completion?(nil)
            return FileWithoutPreview(with: node)
        case .text:
            do {
                let plainTextPreview = PlainTextPreview()
                plainTextPreview.display(text: try Data(contentsOf: url))
                completion?(nil)
                return plainTextPreview
            } catch {
                AlfrescoLog.error("Text file can't be read.")
                completion?(nil)
                return FileWithoutPreview(with: node)
            }

        default:
            completion?(nil)
            return FileWithoutPreview(with: node)
        }
    }
}
