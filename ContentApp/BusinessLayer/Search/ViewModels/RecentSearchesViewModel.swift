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

struct RecentSearchesViewModel {
    var searches: [String] = []

    init() {
        searches = self.recentSearch()
    }

    mutating func reloadRecentSearch() {
        self.searches = self.recentSearch()
    }

    func save(recentSearch string: String?) {
        guard let string = string else { return }
        var recents = self.recentSearch()
        if let indexItem = recents.lastIndex(of: string) {
            recents.remove(at: indexItem)
        }
        recents.insert(string, at: 0)
        if recents.count == kMaxElemetsInRecentSearchesArray + 1 {
            recents.removeLast()
        }
        UserDefaults.standard.set(recents, forKey: kSaveRecentSearchesArray)
        UserDefaults.standard.synchronize()
    }

    private func recentSearch() -> [String] {
        return UserDefaults.standard.array(forKey: kSaveRecentSearchesArray) as? [String] ?? []
    }
}
