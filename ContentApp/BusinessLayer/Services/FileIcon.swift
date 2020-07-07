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

enum IconType: String {
    case arhive = "ic-arhive"
    case audio = "ic-audio"
    case book = "ic-book"
    case cadDrawings = "ic-cad-drawings"
    case database = "ic-database"
    case docsOther = "ic-docs-other"
    case folderEmpty = "ic-folder-empty"
    case folderSmart = "ic-folder-Smart"
    case folder = "ic-folder"
    case forms = "ic-forms"
    case googleDrawings = "ic-googledrawings"
    case googleForms = "ic-googleforms"
    case googleSheets = "ic-googlesheets"
    case googleSlides = "ic-googleslides"
    case image = "ic-image-no-preview"
    case msExcel = "ic-ms-excel"
    case msPowerpoint = "ic-ms-powerpoint"
    case msWord = "ic-ms-word"
    case other = "ic-other"
    case pdf = "ic-pdf"
    case presentationsOther = "ic-presentations-other"
    case spreadsheetsOther = "ic-spreadsheets-other"
    case video = "ic-video"
    case web = "googledrawings"
}

class FileIcon {

    static private var map: [String: IconType] {
        return [
            "application/gzip": .arhive,
            "application/json": .docsOther,
            "application/msaccess": .database,
            "application/msword": .msWord,
            "application/ogg": .audio,
            "application/pdf": .pdf,
            "application/postscript": .image,
            "application/rar": .arhive,
            "application/vnd.apple.keynote": .presentationsOther,
            "application/vnd.apple.numbers": .spreadsheetsOther,
            "application/vnd.apple.pages": .docsOther,
            "application/vnd.ms-excel": .msExcel,
            "application/vnd.ms-powerpoint": .msPowerpoint,
            "application/vnd.oasis.opendocument.database": .database,
            "application/vnd.oasis.opendocument.graphics": .image,
            "application/vnd.oasis.opendocument.graphics-template": .image,
            "application/vnd.oasis.opendocument.image": .image,
            "application/vnd.oasis.opendocument.spreadsheet": .spreadsheetsOther,
            "application/vnd.oasis.opendocument.spreadsheet-template": .spreadsheetsOther,
            "application/vnd.oasis.opendocument.text": .docsOther,
            "application/vnd.oasis.opendocument.text-master": .docsOther,
            "application/vnd.oasis.opendocument.text-template": .docsOther,
            "application/vnd.openxmlformats-officedocument.presentationml.presentation": .msPowerpoint,
            "application/vnd.openxmlformats-officedocument.presentationml.slideshow": .msPowerpoint,
            "application/vnd.openxmlformats-officedocument.presentationml.template": .msPowerpoint,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": .msExcel,
            "application/vnd.openxmlformats-officedocument.spreadsheetml.template": .msExcel,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document": .msWord,
            "application/vnd.openxmlformats-officedocument.wordprocessingml.template": .msWord,
            "application/vnd.stardivision.calc": .spreadsheetsOther,
            "application/vnd.stardivision.impress": .presentationsOther,
            "application/vnd.stardivision.writer": .docsOther,
            "application/vnd.stardivision.writer-global": .docsOther,
            "application/vnd.sun.xml.calc": .spreadsheetsOther,
            "application/vnd.sun.xml.calc.template": .spreadsheetsOther,
            "application/vnd.sun.xml.impress": .presentationsOther,
            "application/vnd.sun.xml.impress.template": .presentationsOther,
            "application/vnd.sun.xml.writer": .docsOther,
            "application/vnd.sun.xml.writer.global": .docsOther,
            "application/vnd.sun.xml.writer.template": .docsOther,
            "application/x-flac": .audio,
            "application/xhtml+xml": .web,
            "application/zip": .arhive,
            "audio/3gpp": .audio,
            "audio/amr": .audio,
            "audio/basic": .audio,
            "audio/midi": .audio,
            "audio/mobile-xmf": .audio,
            "audio/mpeg": .audio,
            "audio/mpegurl": .audio,
            "audio/prs.sid": .audio,
            "audio/x-aiff": .audio,
            "audio/x-gsm": .audio,
            "audio/x-mpegurl": .audio,
            "audio/x-ms-wax": .audio,
            "audio/x-ms-wma": .audio,
            "audio/x-pn-realaudio": .audio,
            "audio/x-realaudio": .audio,
            "audio/x-scpls": .audio,
            "audio/x-sd2": .audio,
            "audio/x-wav": .audio,
            "image/bmp": .image,
            "image/gif": .image,
            "image/ico": .image,
            "image/ief": .image,
            "image/jpeg": .image,
            "image/pcx": .image,
            "image/png": .image,
            "image/svg+xml": .image,
            "image/tiff": .image,
            "image/vnd.adobe.photoshop": .image,
            "image/vnd.djvu": .image,
            "image/vnd.wap.wbmp": .image,
            "image/x-cmu-raster": .image,
            "image/x-coreldraw": .image,
            "image/x-coreldrawpattern": .image,
            "image/x-coreldrawtemplate": .image,
            "image/x-corelphotopaint": .image,
            "image/x-icon": .image,
            "image/x-jg": .image,
            "image/x-jng": .image,
            "image/x-ms-bmp": .image,
            "image/x-photoshop": .image,
            "image/x-portable-anymap": .image,
            "image/x-portable-bitmap": .image,
            "image/x-portable-graymap": .image,
            "image/x-portable-pixmap": .image,
            "image/x-rgb": .image,
            "image/x-xbitmap": .image,
            "image/x-xpixmap": .image,
            "image/x-xwindowdump": .image,
            "text/comma-separated-values": .docsOther,
            "text/html": .web,
            "text/plain": .docsOther,
            "text/richtext": .docsOther,
            "text/rtf": .docsOther,
            "text/tab-separated-values": .docsOther,
            "text/text": .docsOther,
            "text/xml": .docsOther,
            "video/3gpp": .video,
            "video/dl": .video,
            "video/dv": .video,
            "video/fli": .video,
            "video/m4v": .video,
            "video/mp4": .video,
            "video/mpeg": .video,
            "video/quicktime": .video,
            "video/vnd.mpegurl": .video,
            "video/x-la-asf": .video,
            "video/x-mng": .video,
            "video/x-ms-asf": .video,
            "video/x-ms-wm": .video,
            "video/x-ms-wmv": .video,
            "video/x-ms-wmx": .video,
            "video/x-ms-wvx": .video,
            "video/x-msvideo": .video,
            "video/x-sgi-movie": .video,
            "video/x-webex": .video
        ]
    }

    static func icon(for mimetype: String?) -> UIImage? {
        guard let mimetype = mimetype else {
            return UIImage(named: IconType.other.rawValue)
        }
        if let iconType = self.map[mimetype] {
            return UIImage(named: iconType.rawValue)
        }
        return UIImage(named: IconType.other.rawValue)
    }
}
