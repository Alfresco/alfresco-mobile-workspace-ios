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
import AlfrescoContent

let kRequestDefaultsFieldName = "keywords"

struct SearchRequestBuilder {
    static var repository = ApplicationBootstrap.shared().repository
    static var accountService = repository.service(of: AccountService.identifier) as? AccountService

    static func searchRequest(_ string: String, chipFilters: [SearchChipItem], pagination: RequestPagination?) -> SearchRequest {
        return SearchRequest(query: self.requestQuery(string),
                             paging: pagination ?? self.requestPagination(),
                             include: self.requestInclude(chipFilters),
                             includeRequest: nil,
                             fields: nil,
                             sort: self.searchRequestSort(),
                             templates: self.searchRequestTemplates(),
                             defaults: self.searchRequestDefaults(),
                             localization: nil,
                             filterQueries: self.searchRequestFilter(chipFilters),
                             facetQueries: nil,
                             facetFields: nil,
                             facetIntervals: nil,
                             pivots: nil,
                             stats: nil,
                             spellcheck: nil,
                             scope: nil,
                             limits: nil,
                             highlight: nil,
                             ranges: nil)
    }

    static func recentRequest(pagination: RequestPagination?) -> SearchRequest {
        return SearchRequest(query: self.requestQuery(""),
                             paging: pagination ?? self.requestPagination(),
                             include: self.requestInclude(nil),
                             includeRequest: nil,
                             fields: nil, sort: self.recentRequestSort(),
                             templates: nil,
                             defaults: nil,
                             localization: nil,
                             filterQueries: self.recentRequestFilter(),
                             facetQueries: nil,
                             facetFields: nil,
                             facetIntervals: nil,
                             pivots: nil,
                             stats: nil,
                             spellcheck: nil,
                             scope: nil,
                             limits: nil,
                             highlight: nil,
                             ranges: nil)
    }

    // MARK: - Common

    private static func requestQuery(_ string: String) -> RequestQuery {
        return RequestQuery(language: .afts, userQuery: nil, query: string + "*")
    }

    private static func requestPagination() -> RequestPagination {
        return RequestPagination(maxItems: kListPageSize, skipCount: 0)
    }

    private static func requestInclude(_ chipFilters: [SearchChipItem]?) -> RequestInclude? {
        return [kAPIIncludePathNode]
    }

    // MARK: - Search

    private static func searchRequestSort() -> [RequestSortDefinitionInner] {
        return [RequestSortDefinitionInner(type: .field, field: "score", ascending: false)]
    }

    static func searchRequestTemplates() -> RequestTemplates {
        return [RequestTemplatesInner(name: kRequestDefaultsFieldName, template: "%(cm:name cm:title cm:description TEXT TAG)")]
    }

    private static func searchRequestDefaults() -> RequestDefaults {
        return RequestDefaults(textAttributes: nil,
                               defaultFTSOperator: .and,
                               defaultFTSFieldOperator: nil,
                               namespace: nil,
                               defaultFieldName: kRequestDefaultsFieldName)
    }

    private static func searchRequestFilter(_ chipFilters: [SearchChipItem]) -> [RequestFilterQueriesInner] {
        var requestFilters = self.searchMinusRequestFilter()
        requestFilters.append(self.chipsRequestFilter(for: chipFilters))

        if let nodeChipFilterQuerry = self.chipsRequestNodeFilter(for: chipFilters) {
            requestFilters.append(nodeChipFilterQuerry)
        }

        return requestFilters
    }

    private static func searchMinusRequestFilter() -> [RequestFilterQueriesInner] {
        return [RequestFilterQueriesInner(query: "-TYPE:'cm:thumbnail' AND -TYPE:'cm:failedThumbnail' AND -TYPE:'cm:rating'", tags: nil),
                RequestFilterQueriesInner(query: "-cm:creator:System AND -QNAME:comment", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'st:site' AND -ASPECT:'st:siteContainer' AND -ASPECT:'sys:hidden'", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'dl:dataList' AND -TYPE:'dl:todoList' AND -TYPE:'dl:issue'", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'fm:topic' AND -TYPE:'fm:post'", tags: nil),
                RequestFilterQueriesInner(query: "-TYPE:'lnk:link'", tags: nil),
                RequestFilterQueriesInner(query: "-PNAME:'0/wiki'", tags: nil)]
    }

    private static func chipsRequestFilter(for searchChips: [SearchChipItem]) -> RequestFilterQueriesInner {
        let chipFilterQuerry =  RequestFilterQueriesInner(query: searchChips.filter({ $0.selected && ($0.type == .file || $0.type == .folder) }).compactMap({ "+TYPE:" + $0.type.rawValue }).joined(separator: " OR "), tags: nil)
        if let query = chipFilterQuerry.query, query.isEmpty {
            return RequestFilterQueriesInner(query: "+TYPE:'cm:content' OR +TYPE:'cm:folder'", tags: nil)
        }
        return chipFilterQuerry
    }

    private static func chipsRequestNodeFilter(for searchChips: [SearchChipItem]) -> RequestFilterQueriesInner? {
        for chip in searchChips where chip.type == .node && chip.selected {
            return RequestFilterQueriesInner(query: "ANCESTOR:\"workspace://SpacesStore/\(chip.searchInNodeID)\"", tags: nil)
        }
        return nil
    }

    // MARK: - Recent

    private static func recentRequestSort() -> [RequestSortDefinitionInner] {
        return [RequestSortDefinitionInner(type: .field,
                                           field: "cm:modified",
                                           ascending: false)]
    }
    // swiftlint:disable line_length
    private static func recentRequestFilter() -> [RequestFilterQueriesInner] {
        let identifier = accountService?.activeAccount?.identifier ?? ""
        return [RequestFilterQueriesInner(query: "cm:modified:[NOW/DAY-30DAYS TO NOW/DAY+1DAY]", tags: nil),
                RequestFilterQueriesInner(query: "cm:modifier:\(identifier) OR cm:creator:\(identifier)", tags: nil),
                RequestFilterQueriesInner(query: "TYPE:\"content\" AND -PNAME:\"0/wiki\" AND -TYPE:\"app:filelink\" AND -TYPE:\"cm:thumbnail\" AND -TYPE:\"cm:failedThumbnail\" AND -TYPE:\"cm:rating\" AND -TYPE:\"dl:dataList\" AND -TYPE:\"dl:todoList\" AND -TYPE:\"dl:issue\" AND -TYPE:\"dl:contact\" AND -TYPE:\"dl:eventAgenda\" AND -TYPE:\"dl:event\" AND -TYPE:\"dl:task\" AND -TYPE:\"dl:simpletask\" AND -TYPE:\"dl:meetingAgenda\" AND -TYPE:\"dl:location\" AND -TYPE:\"fm:topic\" AND -TYPE:\"fm:post\" AND -TYPE:\"ia:calendarEvent\" AND -TYPE:\"lnk:link\"", tags: nil)]
    }
    // swiftlint:enable line_length
}
