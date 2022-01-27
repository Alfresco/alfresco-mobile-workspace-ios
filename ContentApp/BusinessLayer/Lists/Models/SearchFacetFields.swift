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

// MARK: - Search Facets
class SearchFacets: NSObject {
    var type: String?
    var label: String?
    var buckets = [Buckets]()
    
    init(type: String?,
         label: String?,
         buckets: [GenericBucket]) {
        self.type = type
        self.label = label
       
        var bucket: [Buckets] = []
        for entry in buckets {
            bucket.append(SearchFacets.create(from: entry, and: label))
        }
        self.buckets = bucket
    }
    
    private static func create(from bucket: GenericBucket, and label: String?) -> Buckets {
        var count = bucket.count
        if let value = bucket.metrics?.first?.value {
            let bucketCount = SearchFacets.getCount(value: value)
            count = String(format: "%d", bucketCount)
        }
        
        var bucketLabel = bucket.label
        if SearchFacets.isFileSizeFacet(for: label) {
            let size = (Float(bucketLabel ?? "0.0") ?? 0.0)/1000.0
            bucketLabel = String(format: "%.2f", size)
        }
        
        return Buckets(label: bucketLabel,
                       filterQuery: bucket.filterQuery,
                       count: count)
    }
    
    private static func getCount(value: JSONValue) -> Int {
        guard case .object(let JSON) = value else { return 0}
        guard case .int(let count) = JSON["count"] else {
            guard case .string(let stringCount) = JSON["count"] else { return 0 }
            return Int(stringCount) ?? 0
        }
        return count
    }
    
    private static func isFileSizeFacet(for label: String?) -> Bool {
        if "SEARCH.FACET_FIELDS.SIZE" == label {
            return true
        }
        return false
    }
}

class Buckets: NSObject {
    var label: String?
    var filterQuery: String?
    var count: String?
    
    init(label: String?,
         filterQuery: String?,
         count: String?) {
        self.label = label
        self.filterQuery = filterQuery
        self.count = count
    }
}
