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

struct FacetFilterMapper {
    static func map(_ context: [GenericFacetResponse]) -> [SearchFacets] {
        var nodes: [SearchFacets] = []
        for entry in context {
            nodes.append(self.create(from: entry))
        }
        return nodes
    }

    private static func create(from node: GenericFacetResponse) -> SearchFacets {
        return SearchFacets(type: node.type,
                            label: node.label,
                            buckets: node.buckets)
    }
}
