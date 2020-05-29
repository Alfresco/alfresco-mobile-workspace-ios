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

class KeyboardHandling {
    private var view: UIView?
    private var object: UIView?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func adaptFrame(in view: UIView, subview: UIView) {
        self.view = view
        self.object = subview
    }

    // MARK: - Keyboard Notification

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let view = self.view, let object = self.object,
            let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue  else {
            return
        }
        let frameObjectInView = view.convert(object.frame, to: UIApplication.shared.windows[0])
        let keyboardHeight = keyboardFrame.cgRectValue.height
        let windowHeight = UIApplication.shared.windows[0].frame.size.height

        let objectPositionYInSuperview = view.frame.size.height - (frameObjectInView.origin.y + frameObjectInView.size.height)
        let objectPositionYInWindow = windowHeight - (frameObjectInView.origin.y + frameObjectInView.size.height)
        let objectPositionY = ((UIDevice.current.userInterfaceIdiom == .phone)) ? objectPositionYInSuperview : objectPositionYInWindow

        if objectPositionY < keyboardHeight {
            view.superview?.frame.origin.y -= (keyboardHeight - objectPositionY)
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        guard let view = self.view else {
            return
        }
        if view.superview?.frame.origin.y != 0 {
            view.superview?.frame.origin.y = 0
        }
    }
}
