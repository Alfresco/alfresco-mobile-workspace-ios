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

// MARK: - Facet Filter Node
class SearchFacets: NSObject {
    var type: String?
    var label: String?
    var buckets = [Buckets]()
    
    init(type: String?,
         label: String?,
         buckets: [GenericBucket]?) {
        self.type = type
        self.label = label
       
        var bucket: [Buckets] = []
        if let buckets = buckets {
            for entry in buckets {
                bucket.append(SearchFacets.create(from: entry))
            }
        }
        self.buckets = bucket
    }
    
    private static func create(from bucket: GenericBucket) -> Buckets {
        return Buckets(label: bucket.label,
                       filterQuery: bucket.filterQuery,
                       metrics: bucket.metrics)
    }
}

class Buckets: NSObject {
    var label: String?
    var filterQuery: String?
    var metrics = [Metrics]()
    
    init(label: String?,
         filterQuery: String?,
         metrics: [GenericMetric]?) {
        self.label = label
        self.filterQuery = filterQuery

        var metric: [Metrics] = []
        if let metrics = metrics {
            for entry in metrics {
                metric.append(Buckets.create(from: entry))
            }
        }
        self.metrics = metric
    }
    
    private static func create(from metric: GenericMetric) -> Metrics {
        return Metrics(type: metric.type,
                       value: metric.value)
    }
}

class Metrics: NSObject {
    var type: String?
    var value: String?
    
    init(type: String?,
         value: JSONValue?) {
        self.type = type
        if let value = value {
            guard case .object(let JSON) = value else { return }
            guard case .string(let count) = JSON["count"] else { return }
            self.value = count
        }
    }
}
