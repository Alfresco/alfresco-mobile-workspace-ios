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

import Foundation
import AlfrescoContentServices

struct SearchRequestBuilder {
    static func searchRequest(_ string: String, chipFilters: [SearchChipItem]) -> SearchRequest {
        let requestQuery = RequestQuery(language: .afts, userQuery: nil, query: string + "*")
        let defaultRequest = self.defaultRequest()

        let templates = RequestTemplates([defaultTemplate(name: defaultRequest.defaultFieldName)])

        var filterQueries = self.defaultNoFilters()
        let chipFilterQuerry = self.requestFilter(for: chipFilters)

        if let query = chipFilterQuerry.query, query.isEmpty {
            filterQueries.append(defaultFilesAndFolderFilter())
        } else {
            filterQueries.append(chipFilterQuerry)
        }

        let sortRequest = RequestSortDefinition([self.defaultSort()])

        let searchRequest = SearchRequest(query: requestQuery, paging: self.defaultPaging(), include: ["path"], includeRequest: nil, fields: nil, sort: sortRequest, templates: templates, defaults: defaultRequest, localization: nil, filterQueries: filterQueries, facetQueries: nil, facetFields: nil, facetIntervals: nil, pivots: nil, stats: nil, spellcheck: nil, scope: nil, limits: nil, highlight: nil, ranges: nil)
        return searchRequest
    }

    private static func requestFilter(for searchChips: [SearchChipItem]) -> RequestFilterQueriesInner {
        return RequestFilterQueriesInner(query: searchChips.filter({ $0.selected }).compactMap({ "+TYPE:" + $0.cmdType }).joined(separator: " OR "),
                                         tags: nil)
    }

    private static func defaultRequest() -> RequestDefaults {
        return RequestDefaults(textAttributes: nil,
                               defaultFTSOperator: .and,
                               defaultFTSFieldOperator: nil,
                               namespace: nil,
                               defaultFieldName: "keywords")
    }

    private static func defaultTemplate(name: String?) -> RequestTemplatesInner {
        return RequestTemplatesInner(name: name, template: "%(cm:name cm:title cm:description TEXT TAG)")
    }

    private static func defaultFilesAndFolderFilter() -> RequestFilterQueriesInner {
        return RequestFilterQueriesInner(query: "+TYPE:'cm:content' OR +TYPE:'cm:folder'", tags: nil)
    }

    private static func defaultNoFilters() -> [RequestFilterQueriesInner] {
        return [RequestFilterQueriesInner(query: "-TYPE:'cm:thumbnail' AND -TYPE:'cm:failedThumbnail' AND -TYPE:'cm:rating'", tags: nil),
                RequestFilterQueriesInner(query: "-cm:creator:System AND -QNAME:comment", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'st:site' AND -ASPECT:'st:siteContainer' AND -ASPECT:'sys:hidden'", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'dl:dataList' AND -TYPE:'dl:todoList' AND -TYPE:'dl:issue'", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'fm:topic' AND -TYPE:'fm:post'", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'lnk:link'", tags: nil),
                RequestFilterQueriesInner(query: "-PNAME:'0/wiki'", tags: nil)]
    }

    private static func defaultSort() -> RequestSortDefinitionInner {
        return RequestSortDefinitionInner(type: .field, field: "score", ascending: false)
    }

    private static func defaultPaging() -> RequestPagination {
        return RequestPagination(maxItems: 25, skipCount: 0)
    }
}
