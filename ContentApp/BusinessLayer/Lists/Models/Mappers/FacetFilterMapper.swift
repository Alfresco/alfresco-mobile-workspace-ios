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

// MARK: - Facet Filter Mapper
struct FacetFilterMapper {
    static func map(_ context: [GenericFacetResponse]) -> [SearchFacetFields] {
        var nodes: [SearchFacetFields] = []
        for entry in context {
            nodes.append(self.create(from: entry))
        }
        return nodes
    }

    private static func create(from node: GenericFacetResponse) -> SearchFacetFields {
        var buckets = [GenericBucket]()
        if let nodeBuckets = node.buckets {
            buckets = nodeBuckets
        }
        return SearchFacetFields(type: node.type,
                            label: node.label,
                            buckets: buckets)
    }
}

// MARK: - Facet Queries Mapper
struct FacetQueriesMapper {
    static func map(_ context: [ResultSetContextFacetQueries]) -> [SearchFacetQueries] {
        var queries: [SearchFacetQueries] = []
        for query in context {
            queries.append(self.create(from: query))
        }
        return queries
    }
    
    private static func create(from query: ResultSetContextFacetQueries) -> SearchFacetQueries {
        return SearchFacetQueries(filterQuery: query.filterQuery,
                                  label: query.label,
                                  count: query.count)
    }
}

// MARK: - Facet Interval Mapper
struct FacetIntervalMapper {
    static func map(_ context: [ResultBuckets]) -> [SearchFacetIntervals] {
        var intervals: [SearchFacetIntervals] = []
        for interval in context {
            intervals.append(self.create(from: interval))
        }
        return intervals
    }
    
    private static func create(from query: ResultBuckets) -> SearchFacetIntervals {
        var buckets = [ResultBucketsBuckets]()
        if let queryBuckets = query.buckets {
            buckets = queryBuckets
        }
        return SearchFacetIntervals(label: query.label,
                                    buckets: buckets)
    }
}
