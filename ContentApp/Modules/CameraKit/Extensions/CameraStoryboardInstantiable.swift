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

enum SegueIdentifiers: String {
    case showPreviewVCfromCameraVC
}

protocol CameraStoryboardInstantiable: NSObjectProtocol {
    associatedtype ViewControllerType
    static var defaultFileName: String { get }
    static func instantiateViewController(_ bundle: Bundle?) -> ViewControllerType
}

extension CameraStoryboardInstantiable where Self: UIViewController {
    static var defaultStoryboardName: String {
        return "Camera"
    }
    static var defaultFileName: String {
        return NSStringFromClass(Self.self).components(separatedBy: ".").last!
    }

    static func instantiateViewController(_ bundle: Bundle? = nil) -> Self {
        let fileName = defaultFileName
        let storyboardName = defaultStoryboardName
        let viewController = UIStoryboard(name: storyboardName, bundle: bundle).instantiateViewController(withIdentifier: fileName)

        // swiftlint:disable force_cast
        return viewController as! Self
        // swiftlint:enable force_cast
    }
}
