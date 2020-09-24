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

enum IconType: String {
    case arhive = "ic-archive"
    case audio = "ic-audio"
    case book = "ic-book"
    case code = "ic-code"
    case database = "ic-database"
    case document = "ic-document"
    case email = "ic-email"
    case folder = "ic-folder_full"
    case folderShared = "ic-folder_shared"
    case folderSmart = "ic-folder_smart"
    case forms = "ic-forms"
    case generic = "ic-generic"
    case graphics = "ic-graphics"
    case image = "ic-image"
    case msDocument = "ic-ms_document"
    case msForm = "ic-ms_form"
    case msPresentation = "ic-ms_presentation"
    case msSpreadsheet = "ic-ms_spreadsheet"
    case pdf = "ic-pdf"
    case presentation = "ic-presentation"
    case process = "ic-process"
    case spreadsheet = "ic-spreadsheet"
    case task = "ic-task"
    case video = "ic-video"
    case site = "ic-site"
}

class FileIcon {
    static private var map: [String: IconType] {
        return [
            "application/acp": .arhive,
            "application/dita+xml": .code,
            "application/eps": .image,
            "application/framemaker": .document,
            "application/illustrator": .image,
            "application/java": .generic,
            "application/java-archive": .arhive,
            "application/json": .code,
            "application/mac-binhex40": .generic,
            "application/msword": .msDocument,
            "application/octet-stream": .generic,
            "application/oda": .document,
            "application/ogg": .audio,
            "application/pagemaker": .document,
            "application/pdf": .pdf,
            "application/postscript": .image,
            "application/remote-printing": .document,
            "application/rss+xml": .code,
            "application/rtf": .document,
            "application/sgml": .code,
            "application/vnd.adobe.aftereffects.project": .generic,
            "application/vnd.adobe.aftereffects.template": .generic,
            "application/vnd.adobe.air-application-installer-package+zip": .arhive,
            "application/vnd.adobe.xdp+xml": .generic,
            "application/vnd.android.package-archive": .arhive,
            "application/vnd.apple.keynote": .presentation,
            "application/vnd.apple.numbers": .spreadsheet,
            "application/vnd.apple.pages": .document,
            "application/vnd.ms-excel": .msSpreadsheet,
            "application/vnd.ms-excel.addin.macroenabled.12": .msSpreadsheet,
            "application/vnd.ms-excel.sheet.binary.macroenabled.12": .msSpreadsheet,
            "application/vnd.ms-excel.sheet.macroenabled.12": .msSpreadsheet,
            "application/vnd.ms-excel.template.macroenabled.12": .msSpreadsheet,
            "application/vnd.ms-outlook": .email,
            "application/vnd.ms-powerpoint": .msPresentation,
            "application/vnd.ms-powerpoint.addin.macroenabled.12": .msPresentation,
            "application/vnd.ms-powerpoint.presentation.macroenabled.12": .msPresentation,
            "application/vnd.ms-powerpoint.slide.macroenabled.12": .msPresentation,
            "application/vnd.ms-powerpoint.slideshow.macroenabled.12": .msPresentation,
            "application/vnd.ms-powerpoint.template.macroenabled.12": .msPresentation,
            "application/vnd.ms-project": .process,
            "application/vnd.ms-word.document.macroenabled.12": .msDocument,
            "application/vnd.ms-word.template.macroenabled.12": .msDocument,
            "application/vnd.oasis.opendocument.chart": .generic,
            "application/vnd.oasis.opendocument.database": .database,
            "application/vnd.oasis.opendocument.formula": .generic,
            "application/vnd.oasis.opendocument.graphics": .image,
            "application/vnd.oasis.opendocument.graphics-template": .image,
            "application/vnd.oasis.opendocument.image": .image,
            "application/vnd.oasis.opendocument.presentation": .presentation,
            "application/vnd.oasis.opendocument.presentation-template": .presentation,
            "application/vnd.oasis.opendocument.spreadsheet": .spreadsheet,
            "application/vnd.oasis.opendocument.spreadsheet-template": .spreadsheet,
            "application/vnd.oasis.opendocument.text": .document,
            "application/vnd.oasis.opendocument.text-master": .document,
            "application/vnd.oasis.opendocument.text-template": .document,
            "application/vnd.oasis.opendocument.text-web": .document,
            "application/vnd.openxmlformats-officedocument.presentationml.presentation": .presentation,
            "application/vnd.openxmlformats-officedocument.presentationml.slide": .presentation,
            "application/vnd.openxmlformats-officedocument.presentationml.slideshow": .presentation,
            "application/vnd.openxmlformats-officedocument.presentationml.template": .presentation,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": .spreadsheet,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.template": .spreadsheet,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": .document,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.template": .document,
            "application/vnd.stardivision.calc": .spreadsheet,
            "application/vnd.stardivision.chart": .generic,
            "application/vnd.stardivision.draw": .image,
            "application/vnd.stardivision.impress": .presentation,
            "application/vnd.stardivision.impress-packed": .presentation,
            "application/vnd.stardivision.math": .generic,
            "application/vnd.stardivision.writer": .document,
            "application/vnd.stardivision.writer-global": .document,
            "application/vnd.sun.xml.calc": .spreadsheet,
            "application/vnd.sun.xml.calc.template": .spreadsheet,
            "application/vnd.sun.xml.draw": .image,
            "application/vnd.sun.xml.impress": .presentation,
            "application/vnd.sun.xml.impress.template": .presentation,
            "application/vnd.sun.xml.writer": .document,
            "application/vnd.sun.xml.writer.template": .document,
            "application/vnd.visio": .process,
            "application/vnd.visio2013": .process,
            "application/wordperfect": .document,
            "application/x-bcpio": .arhive,
            "application/x-compress": .arhive,
            "application/x-cpio": .arhive,
            "application/x-csh": .image,
            "application/x-dosexec": .generic,
            "application/x-dvi": .document,
            "application/x-fla": .video,
            "application/x-gtar": .arhive,
            "application/x-gzip": .arhive,
            "application/x-hdf": .arhive,
            "application/x-indesign": .image,
            "application/x-javascript": .code,
            "application/x-latex": .document,
            "application/x-mif": .document,
            "application/x-netcdf": .document,
            "application/x-rar-compressed": .arhive,
            "application/x-sh": .code,
            "application/x-shar": .arhive,
            "application/x-shockwave-flash": .video,
            "application/x-sv4cpio": .arhive,
            "application/x-sv4crc": .arhive,
            "application/x-tar": .arhive,
            "application/x-tcl": .code,
            "application/x-tex": .document,
            "application/x-texinfo": .document,
            "application/x-troff": .generic,
            "application/x-troff-man": .generic,
            "application/x-troff-me": .generic,
            "application/x-troff-mes": .generic,
            "application/x-ustar": .arhive,
            "application/x-wais-source": .code,
            "application/x-x509-ca-cert": .generic,
            "application/x-zip": .arhive,
            "application/xhtml+xml": .code,
            "application/zip": .arhive,
            "image/vnd.adobe.premiere": .video,
            "image/vnd.dwg": .generic,
            "image/x-dwt": .generic,
            "message/rfc822": .email,
            "text/calendar": .generic,
            "text/css": .code,
            "text/csv": .spreadsheet,
            "text/html": .code,
            "text/mediawiki": .code,
            "text/plain": .document,
            "text/richtext": .document,
            "text/sgml": .code,
            "text/tab-separated-values": .spreadsheet,
            "text/x-java-source": .code,
            "text/x-jsp": .code,
            "text/x-markdown": .code,
            "text/x-setext": .generic,
            "text/xml": .code,
            "text/x-csrc": .code,
            "x-world/x-vrml": .generic,
            "cm:folder": .folder,
            "st:site": .site
        ]
    }

    static func icon(for mimetype: String?) -> UIImage? {
        guard let mimetype = mimetype else {
            return UIImage(named: IconType.generic.rawValue)
        }
        if let iconType = self.map[mimetype] {
            return UIImage(named: iconType.rawValue)
        } else if mimetype.contains("video/") {
            return UIImage(named: IconType.video.rawValue)
        } else if mimetype.contains("audio/") {
            return UIImage(named: IconType.audio.rawValue)
        } else if mimetype.contains("image/") {
            return UIImage(named: IconType.image.rawValue)
        } else {
            print(mimetype)
        }
        return UIImage(named: IconType.generic.rawValue)
    }
}
