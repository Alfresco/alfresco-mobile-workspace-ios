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

class RecentSearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var titleSearch: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!

    var search: String? {
        didSet {
            if let search = search {
                titleSearch.text = search
            }
        }
    }

    func applyThemingService(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        titleSearch.applyStyleSubtitle1OnSurface(theme: currentTheme)
    }

}
