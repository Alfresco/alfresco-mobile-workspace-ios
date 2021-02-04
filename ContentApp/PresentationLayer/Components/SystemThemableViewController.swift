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

import UIKit

struct ControllerRotation {
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            if UIDevice.current.userInterfaceIdiom != .pad {
                delegate.orientationLock = orientation
            }
        }
    }

    static func lockOrientation(_ orientation: UIInterfaceOrientationMask,
                                andRotateTo rotateOrientation: UIInterfaceOrientation) {
        self.lockOrientation(orientation)

        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
}

class SystemThemableViewController: UIViewController {
    var coordinatorServices: CoordinatorServices?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        applyComponentsThemes()
        ControllerRotation.lockOrientation(.portrait)
    }

    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinatorServices?.themingService?.activateUserSelectedTheme()
        applyComponentsThemes()
        UIApplication.shared.windows[0].backgroundColor = coordinatorServices?.themingService?.activeTheme?.surfaceColor
    }

    func applyComponentsThemes() {
        // Override in subclass
    }
}
