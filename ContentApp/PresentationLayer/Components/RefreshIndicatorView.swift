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
import MaterialComponents.MaterialActivityIndicator

class RefreshIndicatorView: UIRefreshControl {
    private var refreshIndicatorView = MDCActivityIndicator()

    init(theme: PresentationTheme?) {
        super.init()
        self.tintColor = .clear
        refreshIndicatorView.sizeToFit()
        refreshIndicatorView.center = CGPoint(x: self.center.x + refreshIndicatorView.frame.size.width, y: self.center.y)
        refreshIndicatorView.strokeWidth = 2
        refreshIndicatorView.radius = 12
        refreshIndicatorView.startAnimating()
        applyTheme(theme)
        self.addSubview(refreshIndicatorView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func applyTheme(_ theme: PresentationTheme?) {
        refreshIndicatorView.cycleColors = [theme?.primaryVariantT1Color ?? .black]
    }
}
