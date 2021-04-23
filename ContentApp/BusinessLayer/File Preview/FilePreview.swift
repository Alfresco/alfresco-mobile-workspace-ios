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
//  Unless required by applicable law or agreed: in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import UIKit

enum FilePreviewType {
    case image
    case gif
    case svg
    case video
    case audio
    case text
    case pdf
    case rendition
    case noPreview
}

class FilePreview {
    static private var map: [String: FilePreviewType] {
        return [
            "image/gif": .gif,
            "image/webp": .image,
            "image/bmp": .image,
            "image/jpeg": .image,
            "image/png": .image,
            "image/tiff": .image,
            "image/x-portable-bitmap": .image,
            "image/x-portable-graymap": .image,
            "image/x-portable-pixmap": .image,
            "image/vnd.adobe.photoshop": .image,
            "image/heic": .image,
            "image/heif": .image,
            "image/svg+xml": .svg,
            "application/pdf": .pdf
        ]
    }

    static func preview(mimetype: String?) -> FilePreviewType {
        guard let mimetype = mimetype else {
            return .rendition
        }

        if let previewType = self.map[mimetype] {
            return previewType
        } else if mimetype.hasPrefix("video/") {
            return .video
        } else if mimetype.hasPrefix("audio/") {
            return .audio
        } else if mimetype.hasPrefix("text/") {
            return .text
        } else {
            return .rendition
        }
    }
}
