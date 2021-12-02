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

import Foundation
import AlfrescoContent

// MARK: - Facet Intervals
class SearchFacetIntervals: NSObject {
    var label: String?
    var buckets = [Buckets]()
    
    init(label: String?,
         buckets: [ResultBucketsBuckets]) {
        self.label = label
        
        var bucket: [Buckets] = []
        for entry in buckets {
            bucket.append(SearchFacetIntervals.create(from: entry))
        }
        self.buckets = bucket
    }
    
    private static func create(from bucket: ResultBucketsBuckets) -> Buckets {
        let count = "\(bucket.count ?? 0)"
        return Buckets(label: bucket.label,
                       filterQuery: bucket.filterQuery,
                       count: count)
    }
}
