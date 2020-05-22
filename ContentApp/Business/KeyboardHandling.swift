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
    private var positionObjectInSuperview: CGFloat
    private var view: UIView

    init() {
        self.positionObjectInSuperview = 0.0
        self.view = UIView()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func add(positionObjectInSuperview: CGFloat, in view: UIView) {
        self.positionObjectInSuperview = positionObjectInSuperview
        self.view = view
    }

    // MARK: - Keyboard Notification

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardHeight =  keyboardFrame.cgRectValue.height
            let margin = ((UIDevice.current.userInterfaceIdiom == .phone)) ?
                view.frame.size.height - positionObjectInSuperview :
                UIApplication.shared.windows[0].frame.size.height - positionObjectInSuperview
            if view.frame.origin.y == 0 && margin < keyboardHeight {
                view.frame.origin.y -= (keyboardHeight - margin)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
}
