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
    case renditionPdf
    case noPreview
}

class FilePreview {
    static private var map: [String: FilePreviewType] {
        return [
            "application/acp": .renditionPdf,
            "application/dita+xml": .renditionPdf,
            "application/eps": .renditionPdf,
            "application/framemaker": .renditionPdf,
            "application/illustrator": .renditionPdf,
            "application/java": .renditionPdf,
            "application/java-archive": .renditionPdf,
            "application/json": .renditionPdf,
            "application/mac-binhex40": .renditionPdf,
            "application/msword": .renditionPdf,
            "application/octet-stream": .renditionPdf,
            "application/oda": .renditionPdf,
            "application/ogg": .renditionPdf,
            "application/pagemaker": .renditionPdf,
            "application/pdf": .pdf,
            "application/postscript": .renditionPdf,
            "application/remote-printing": .renditionPdf,
            "application/rss+xml": .renditionPdf,
            "application/rtf": .renditionPdf,
            "application/sgml": .renditionPdf,
            "application/vnd.adobe.aftereffects.project": .renditionPdf,
            "application/vnd.adobe.aftereffects.template": .renditionPdf,
            "application/vnd.adobe.air-application-installer-package+zip": .renditionPdf,
            "application/vnd.adobe.xdp+xml": .renditionPdf,
            "application/vnd.android.package-archive": .renditionPdf,
            "application/vnd.apple.keynote": .renditionPdf,
            "application/vnd.apple.numbers": .renditionPdf,
            "application/vnd.apple.pages": .renditionPdf,
            "application/vnd.ms-excel": .renditionPdf,
            "application/vnd.ms-excel.addin.macroenabled.12": .renditionPdf,
            "application/vnd.ms-excel.sheet.binary.macroenabled.12": .renditionPdf,
            "application/vnd.ms-excel.sheet.macroenabled.12": .renditionPdf,
            "application/vnd.ms-excel.template.macroenabled.12": .renditionPdf,
            "application/vnd.ms-outlook": .renditionPdf,
            "application/vnd.ms-powerpoint": .renditionPdf,
            "application/vnd.ms-powerpoint.addin.macroenabled.12": .renditionPdf,
            "application/vnd.ms-powerpoint.presentation.macroenabled.12": .renditionPdf,
            "application/vnd.ms-powerpoint.slide.macroenabled.12": .renditionPdf,
            "application/vnd.ms-powerpoint.slideshow.macroenabled.12": .renditionPdf,
            "application/vnd.ms-powerpoint.template.macroenabled.12": .renditionPdf,
            "application/vnd.ms-project": .renditionPdf,
            "application/vnd.ms-word.document.macroenabled.12": .renditionPdf,
            "application/vnd.ms-word.template.macroenabled.12": .renditionPdf,
            "application/vnd.oasis.opendocument.chart": .renditionPdf,
            "application/vnd.oasis.opendocument.database": .renditionPdf,
            "application/vnd.oasis.opendocument.formula": .renditionPdf,
            "application/vnd.oasis.opendocument.graphics": .renditionPdf,
            "application/vnd.oasis.opendocument.graphics-template": .renditionPdf,
            "application/vnd.oasis.opendocument.image": .renditionPdf,
            "application/vnd.oasis.opendocument.presentation": .renditionPdf,
            "application/vnd.oasis.opendocument.presentation-template": .renditionPdf,
            "application/vnd.oasis.opendocument.spreadsheet": .renditionPdf,
            "application/vnd.oasis.opendocument.spreadsheet-template": .renditionPdf,
            "application/vnd.oasis.opendocument.text": .renditionPdf,
            "application/vnd.oasis.opendocument.text-master": .renditionPdf,
            "application/vnd.oasis.opendocument.text-template": .renditionPdf,
            "application/vnd.oasis.opendocument.text-web": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.presentationml.presentation": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.presentationml.slide": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.presentationml.slideshow": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.presentationml.template": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.template": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": .renditionPdf,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.template": .renditionPdf,
            "application/vnd.stardivision.calc": .renditionPdf,
            "application/vnd.stardivision.chart": .renditionPdf,
            "application/vnd.stardivision.draw": .renditionPdf,
            "application/vnd.stardivision.impress": .renditionPdf,
            "application/vnd.stardivision.impress-packed": .renditionPdf,
            "application/vnd.stardivision.math": .renditionPdf,
            "application/vnd.stardivision.writer": .renditionPdf,
            "application/vnd.stardivision.writer-global": .renditionPdf,
            "application/vnd.sun.xml.calc": .renditionPdf,
            "application/vnd.sun.xml.calc.template": .renditionPdf,
            "application/vnd.sun.xml.draw": .renditionPdf,
            "application/vnd.sun.xml.impress": .renditionPdf,
            "application/vnd.sun.xml.impress.template": .renditionPdf,
            "application/vnd.sun.xml.writer": .renditionPdf,
            "application/vnd.sun.xml.writer.template": .renditionPdf,
            "application/vnd.visio": .renditionPdf,
            "application/vnd.visio2013": .renditionPdf,
            "application/wordperfect": .renditionPdf,
            "application/x-bcpio": .renditionPdf,
            "application/x-compress": .renditionPdf,
            "application/x-cpio": .renditionPdf,
            "application/x-csh": .renditionPdf,
            "application/x-dosexec": .renditionPdf,
            "application/x-dvi": .renditionPdf,
            "application/x-fla": .video,
            "application/x-gtar": .renditionPdf,
            "application/x-gzip": .renditionPdf,
            "application/x-hdf": .renditionPdf,
            "application/x-indesign": .renditionPdf,
            "application/x-javascript": .renditionPdf,
            "application/x-latex": .renditionPdf,
            "application/x-mif": .renditionPdf,
            "application/x-netcdf": .renditionPdf,
            "application/x-rar-compressed": .renditionPdf,
            "application/x-sh": .renditionPdf,
            "application/x-shar": .renditionPdf,
            "application/x-shockwave-flash": .renditionPdf,
            "application/x-sv4cpio": .renditionPdf,
            "application/x-sv4crc": .renditionPdf,
            "application/x-tar": .renditionPdf,
            "application/x-tcl": .renditionPdf,
            "application/x-tex": .renditionPdf,
            "application/x-texinfo": .renditionPdf,
            "application/x-troff": .renditionPdf,
            "application/x-troff-man": .renditionPdf,
            "application/x-troff-me": .renditionPdf,
            "application/x-troff-mes": .renditionPdf,
            "application/x-ustar": .renditionPdf,
            "application/x-wais-source": .renditionPdf,
            "application/x-x509-ca-cert": .renditionPdf,
            "application/x-zip": .renditionPdf,
            "application/xhtml+xml": .renditionPdf,
            "application/zip": .renditionPdf,
            "audio/basic": .audio,
            "audio/mp4": .audio,
            "audio/mpeg": .audio,
            "audio/ogg": .audio,
            "audio/vnd.adobe.soundbooth": .audio,
            "audio/vorbis": .audio,
            "audio/x-aiff": .audio,
            "audio/x-flac": .audio,
            "audio/x-ms-wma": .audio,
            "audio/x-wav": .audio,
            "image/bmp": .image,
            "image/cgm": .image,
            "image/gif": .gif,
            "image/ief": .image,
            "image/jp2": .image,
            "image/jpeg": .image,
            "image/png": .image,
            "image/svg+xml": .svg,
            "image/tiff": .image,
            "image/vnd.adobe.photoshop": .image,
            "image/vnd.adobe.premiere": .image,
            "image/vnd.dwg": .image,
            "image/x-cmu-raster": .image,
            "image/x-dwt": .image,
            "image/x-portable-anymap": .image,
            "image/x-portable-bitmap": .image,
            "image/x-portable-graymap": .image,
            "image/x-portable-pixmap": .image,
            "image/x-raw-adobe": .image,
            "image/x-raw-canon": .image,
            "image/x-raw-fuji": .image,
            "image/x-raw-hasselblad": .image,
            "image/x-raw-kodak": .image,
            "image/x-raw-leica": .image,
            "image/x-raw-minolta": .image,
            "image/x-raw-nikon": .image,
            "image/x-raw-olympus": .image,
            "image/x-raw-panasonic": .image,
            "image/x-raw-pentax": .image,
            "image/x-raw-red": .image,
            "image/x-raw-sigma": .image,
            "image/x-raw-sony": .image,
            "image/x-rgb": .image,
            "image/x-xbitmap": .image,
            "image/x-xpixmap": .image,
            "image/x-xwindowdump": .image,
            "message/rfc822": .renditionPdf,
            "text/calendar": .text,
            "text/css": .text,
            "text/csv": .text,
            "text/html": .text,
            "text/mediawiki": .text,
            "text/plain": .text,
            "text/richtext": .text,
            "text/sgml": .text,
            "text/tab-separated-values": .text,
            "text/x-java-source": .text,
            "text/x-jsp": .text,
            "text/x-markdown": .text,
            "text/x-setext": .text,
            "text/xml": .text,
            "text/x-csrc": .text,
            "video/3gpp": .video,
            "video/3gpp2": .video,
            "video/mp2t": .video,
            "video/mp4": .video,
            "video/mpeg": .video,
            "video/mpeg2": .video,
            "video/ogg": .video,
            "video/quicktime": .video,
            "video/webm": .video,
            "video/x-flv": .video,
            "video/x-m4v": .video,
            "video/x-ms-asf": .video,
            "video/x-ms-wmv": .video,
            "video/x-msvideo": .video,
            "video/x-rad-screenplay": .video,
            "video/x-sgi-movie": .video,
            "x-world/x-vrml": .renditionPdf
        ]
    }

    static func preview(mimetype: String?) -> FilePreviewType {
        guard let mimetype = mimetype else {
            return .renditionPdf
        }
        if let previewType = self.map[mimetype] {
            return previewType
        } else {
            return .renditionPdf
        }
    }
}
