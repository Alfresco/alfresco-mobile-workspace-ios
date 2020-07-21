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

class ActivityIndicatorFooterView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let activityIndicator = MDCActivityIndicator()
        activityIndicator.cycleColors =  [#colorLiteral(red: 0.137254902, green: 0.3960784314, blue: 0.8549019608, alpha: 1)]
        activityIndicator.radius = 15
        activityIndicator.strokeWidth = 4
        activityIndicator.sizeToFit()
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        activityIndicator.center = CGPoint(x: self.center.x, y: activityIndicator.frame.origin.y + activityIndicator.frame.size.height / 2)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
