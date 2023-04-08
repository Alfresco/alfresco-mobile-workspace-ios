//
// Copyright (C) 2005-2023 Alfresco Software Limited.
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
import AlfrescoContent

class StartableWorkflowsViewModel: NSObject {
    var services: CoordinatorServices?
    var appDefinitions = [WFlowAppDefinitions]()
    weak var delegate: ActionMenuViewModelDelegate?

    func numberOfActions() -> CGFloat {
        return CGFloat(appDefinitions.count)
    }

    // MARK: - Workflows List
    
    func fetchWorkflowsList(completionHandler: @escaping (_ appDefinitions: [WFlowAppDefinitions], _ error: Error?) -> Void) {
        
        services?.accountService?.getSessionForCurrentAccount(completionHandler: { authenticationProvider in
            AlfrescoContentAPI.customHeaders = authenticationProvider.authorizationHeader()
            
            ProcessAPI.runtimeAppDefinition() {[weak self] data, error in
                guard let sSelf = self else { return }

                if data != nil {
                    let appDefinitions = data?.data ?? []
                    sSelf.appDefinitions = WFlowAppDefinitionOperations.processNodes(for: appDefinitions)
                    sSelf.delegate?.finishedLoadingActions()
                    completionHandler(sSelf.appDefinitions, nil)
                } else {
                    sSelf.delegate?.finishedLoadingActions()
                    completionHandler([], error)
                }
            }
        })
    }
}
