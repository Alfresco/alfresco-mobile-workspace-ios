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

protocol PageFetchableDelegate: AnyObject {
    func fetchNextContentPage(for collectionView: UICollectionView, itemAtIndexPath: IndexPath)
    func isPaginationEnabled() -> Bool
}

class PageFetchableCollectionView: UICollectionView {
    weak var pageDelegate: PageFetchableDelegate?

    private var lastItemIndexPath: IndexPath?

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.prefetchDataSource = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        lastItemIndexPath = self.lastItemIndexPath()
    }
}

extension PageFetchableCollectionView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let isPaginationEnabled = pageDelegate?.isPaginationEnabled() else { return }

        if isPaginationEnabled {
            for indexPath in indexPaths where indexPath == lastItemIndexPath {
                pageDelegate?.fetchNextContentPage(for: self, itemAtIndexPath: indexPath)
            }
        }
    }
}
