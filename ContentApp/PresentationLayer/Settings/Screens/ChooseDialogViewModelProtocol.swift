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

import UIKit

class ChooseItem: Equatable {
    var guid: Int
    var selected: Bool
    var title: String

    init(guid: Int, title: String, selected: Bool = false) {
        self.guid = guid
        self.title = title
        self.selected = selected
    }

    static func == (lhs: ChooseItem, rhs: ChooseItem) -> Bool {
        return lhs.guid == rhs.guid
    }
}

protocol ChooseDialogViewModelDelegate: class {
    func chosen(item: ChooseItem)
}

protocol ChooseDialogViewModelProtocol {
    var titleDialog: String { get }
    var items: [ChooseItem] { get set }
    var chooseDialogDelegate: ChooseDialogViewModelDelegate? { get set }
    func perfomAction(for item: ChooseItem)
}

extension ChooseDialogViewModelProtocol {
    func select(item: ChooseItem) {
        item.selected = true
        for cItem in items where cItem != item {
            cItem.selected = false
        }
        self.chooseDialogDelegate?.chosen(item: item)
    }
}
