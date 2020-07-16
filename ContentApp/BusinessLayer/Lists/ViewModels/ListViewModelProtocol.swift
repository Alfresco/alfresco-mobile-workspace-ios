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
import AlfrescoContentServices

protocol ListViewModelProtocol {
    var listRequest: SearchRequest? { get set }
    var resultsList: [ListElementProtocol] { get set }
    var viewModelDelegate: ListViewModelDelegate? { get set }
    
    init(with accountService: AccountService?, listRequest: SearchRequest?)
    func getAvatar(completionHandler: @escaping ((UIImage?) -> Void)) -> UIImage?
}

protocol ListViewModelDelegate: class {
    /**
     Handle search results
     - results: list of element from a search operation
     - Note: If the list  is empty,  a view with empty list will appear.  If the list is a nil object then recent searches will appear
     */
    func handleRecent(results: [ListElementProtocol]?)
}
