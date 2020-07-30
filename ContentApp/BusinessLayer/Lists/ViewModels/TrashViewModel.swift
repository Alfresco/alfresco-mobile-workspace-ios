////
//// Copyright (C) 2005-2020 Alfresco Software Limited.
////
//// This file is part of the Alfresco Content Mobile iOS App.
////
//// Licensed under the Apache License, Version 2.0 (the "License");
//// you may not use this file except in compliance with the License.
//// You may obtain a copy of the License at
////
////  http://www.apache.org/licenses/LICENSE-2.0
////
////  Unless required by applicable law or agreed to in writing, software
////  distributed under the License is distributed on an "AS IS" BASIS,
////  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
////  See the License for the specific language governing permissions and
////  limitations under the License.
////
//
//import Foundation
//import UIKit
//import AlfrescoAuth
//import AlfrescoContentServices
//
//class TrashViewModel: ListViewModelProtocol {
//    var accountService: AccountService?
//    var listRequest: SearchRequest?
//    var groupedLists: [GroupedList] = []
//    weak var delegate: ListViewModelDelegate?
//
//    // MARK: - Init
//
//    required init(with accountService: AccountService?, listRequest: SearchRequest?) {
//        self.accountService = accountService
//        self.listRequest = listRequest
//    }
//
//    // MARK: Public Methods
//
//    func reloadRequest() {
//        groupedLists = []
//        personalFilesRequest()
//    }
//
//    func shouldDisplaySections() -> Bool {
//        return false
//    }
//
//    func shouldDisplaySettingsButton() -> Bool {
//        return false
//    }
//
//    // MARK: Private Methods
//
//    func personalFilesRequest() {
//        accountService?.getSessionForCurrentAccount(completionHandler: { [weak self] authenticationProvider in
//            guard let sSelf = self else { return }
//            AlfrescoContentServicesAPI.customHeaders = authenticationProvider.authorizationHeader()
//            TrashcanAPI.listDeletedNodes(skipCount: 0, maxItems: 25, include: ["path"]) { (result, error) in
//                if let entries = result?.list?.entries {
//                    sSelf.groupedLists.append(GroupedList(type: .none, list: DeleteNodeMapper.map(entries)))
//                    DispatchQueue.main.async {
//                        sSelf.delegate?.handleList()
//                    }
//                } else {
//                    if let error = error {
//                        AlfrescoLog.error(error)
//                    }
//                    DispatchQueue.main.async {
//                        sSelf.delegate?.handleList()
//                    }
//                }
//            }
//        })
//    }
//}
