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

protocol ResultsViewModelDelegate: class {
    func refreshResults()
}

class ResultsViewModel: PageFetchingViewModel, EventObservable {
    var supportedNodeTypes: [ElementKindType]?
    weak var delegate: ResultsViewModelDelegate?

    override func updatedResults(results: [ListNode], pagination: Pagination) {
        pageUpdatingDelegate?.didUpdateList(error: nil,
                                            pagination: pagination)
    }

    // MARK: Event observable

    func handle(event: BaseNodeEvent, on queue: EventQueueType) {
        if let publishedEvent = event as? FavouriteEvent {
            let node = publishedEvent.node
            for listNode in results where listNode == node {
                listNode.favorite = node.favorite
            }
        } else if let publishedEvent = event as? MoveEvent {
            let node = publishedEvent.node
            switch publishedEvent.eventType {
            case .moveToTrash:
                if node.kind == .file {
                    if let indexOfMovedNode = results.firstIndex(of: node) {
                        results.remove(at: indexOfMovedNode)
                    }
                } else {
                    refreshList()
                }
            case .restore:
                refreshList()
            default: break
            }
        }
    }
}

// MARK: - SearchViewModelDelegate

extension ResultsViewModel: SearchViewModelDelegate {
    func handle(results: [ListNode]?, pagination: Pagination?, error: Error?) {
        updateResults(results: results, pagination: pagination, error: error)
    }
}

// MARK: - ListCcomponentDataSourceProtocol

extension ResultsViewModel: ListComponentDataSourceProtocol {
    func isEmpty() -> Bool {
        return results.isEmpty
    }

    func emptyList() -> EmptyListProtocol {
        return EmptySearch()
    }

    func shouldDisplaySections() -> Bool {
        return false
    }

    func numberOfSections() -> Int {
        return (results.count == 0) ? 0 : 1
    }

    func numberOfItems(in section: Int) -> Int {
        return results.count
    }

    func listNode(for indexPath: IndexPath) -> ListNode {
        return results[indexPath.row]
    }

    func titleForSectionHeader(at indexPath: IndexPath) -> String {
        return ""
    }

    func shouldDisplayListLoadingIndicator() -> Bool {
        return self.shouldDisplayNextPageLoadingIndicator
    }

    func shouldDisplayMoreButton() -> Bool {
        return true
    }

    func shouldDisplayNodePath() -> Bool {
        return true
    }

    func refreshList() {
        currentPage = 1
        delegate?.refreshResults()
    }

    func updateDetails(for listNode: ListNode?, completion: @escaping ((ListNode?, Error?) -> Void)) {
        guard let node = listNode else { return }
        if node.kind == .site {
            FavoritesAPI.getFavorite(personId: kAPIPathMe,
                                     favoriteId: node.guid) { (_, error) in
                if error == nil {
                    node.favorite = true
                }
                completion(node, error)
            }
        } else {
            NodesAPI.getNode(nodeId: node.guid,
                             include: [kAPIIncludePathNode,
                                       kAPIIncludeAllowableOperationsNode,
                                       kAPIIncludeIsFavoriteNode],
                             relativePath: nil,
                             fields: nil) { (result, error) in
                if let entry = result?.entry {
                    let listNode = NodeChildMapper.create(from: entry)
                    completion(listNode, error)
                } else {
                    completion(listNode, error)
                }
            }
        }
    }
}
