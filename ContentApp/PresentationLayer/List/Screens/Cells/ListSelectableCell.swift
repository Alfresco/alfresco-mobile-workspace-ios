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

import MaterialComponents.MaterialInk

class ListSelectableCell: UICollectionViewCell {
    private var inkView: MDCInkView?
    private var lastTouch: CGPoint?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let inkView = MDCInkView(frame: bounds)
        inkView.usesLegacyInkRipple = false
        addSubview(inkView)
        self.inkView = inkView
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        let location = touch?.location(in: self)
        lastTouch = location

        super.touchesBegan(touches, with: event)
    }

    override var isHighlighted: Bool {
        set {
            super.isHighlighted = newValue
            guard let lastTouch = self.lastTouch else { return }
            if newValue {
                inkView?.startTouchBeganAnimation(at: lastTouch, completion: nil)
            } else {
                inkView?.startTouchEndedAnimation(at: lastTouch, completion: nil)
            }
        }

        get {
            return true
        }
    }

    override func prepareForReuse() {
        inkView?.cancelAllAnimations(animated: false)
        super.prepareForReuse()
    }
}
