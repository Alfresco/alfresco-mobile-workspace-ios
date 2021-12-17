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

typealias SearchComponentCallBack = (SearchCategories?, String?, Bool) -> Void
typealias FacetComponentsCallBack = (_ value: String?, _ query: String?, _ isBackPressed: Bool) -> Void

class SearchViewModel: ListComponentViewModel {
    var searchModel: SearchModelProtocol
    init(model: SearchModelProtocol) {
        searchModel = model
        super.init(model: model)
    }
    
    /// selected category
    var selectedCategory: SearchCategories?
    
    /// selected chip
    var selectedChip: SearchChipItem?
    
    /// search filter observable
    let searchFilterObservable = Observable<[AdvanceSearchFilters]>([])
    
    /// search filters array
    var searchFilters: [AdvanceSearchFilters] {
        get {
            return searchFilterObservable.value
        }
        set (newValue) {
            searchFilterObservable.value = newValue
        }
    }
    
    var isShowResetFilter: Bool {
        if let selectedSearchFilter = self.searchModel.selectedSearchFilter {
            return selectedSearchFilter.resetButton ?? false
        }
        return false
    }
    
    /// all filters names
    var filterNames: [String] { 
        let filtered = searchFilters.map {$0.name ?? ""}
        return filtered
    }
    
    /// localized filter names
    var localizedFilterNames: [String] {
        var names = [String]()
        for name in filterNames {
            let localizedName = NSLocalizedString(name, comment: "")
            names.append(localizedName)
        }
        return names
    }
    
    // Facet Filters
    var facetFields = [SearchFacetFields]()
    var facetQueries = [SearchFacetQueries]()
    var facetIntervals = [SearchFacetIntervals]()
    
    /// selected filter name
    func selectedFilterName(for config: AdvanceSearchFilters?) -> String {
        if let config = config {
            return NSLocalizedString(config.name ?? "", comment: "")
        }
        return LocalizationConstants.AdvanceSearch.title
    }
    
    /// default search filter
    func defaultSearchFilter() -> AdvanceSearchFilters? {
        if let index = searchFilters.firstIndex(where: {$0.isDefault == true}) {
              return searchFilters[index]
        }
        return nil
    }
    
    func isShowAdvanceFilterView(array: [String]) -> Bool {
        if array.isEmpty {
            return false
        }
        return true
    }
    
    override func emptyList() -> EmptyListProtocol {
        return EmptySearch()
    }

    func shouldDisplaySearchBar() -> Bool {
        return true
    }

    func shouldDisplaySearchButton() -> Bool {
        return true
    }
    
    func isAdvanceSearchFiltersAllowedFromServer() -> Bool {
        if  self.isChipSelected() == true {
            return false
        } else {
            let apiInterval = ConfigurationManager.shared.getAdvanceSearchAPIInterval()
            if UserDefaults.standard.bool(forKey: KeyConstants.AdvanceSearch.fetchAdvanceSearchFromServer) == true || self.isTimeExceedsForAdvanceSearchConfig(apiInterval: apiInterval) {
                self.updateSearchConfigurationKeys()
                return true
            }
            return false
        }
    }

    func isTimeExceedsForAdvanceSearchConfig(apiInterval: Int) -> Bool {
        let hours = lastAPICallDifferenceInHours()
        if hours >= apiInterval {
            return true
        }
        return false
    }
    
    func updateSearchConfigurationKeys() {
        UserDefaults.standard.set(false, forKey: KeyConstants.AdvanceSearch.fetchAdvanceSearchFromServer)
        UserDefaults.standard.set(Date().currentTimeMillis(), forKey: KeyConstants.AdvanceSearch.lastAPICallTime)
        UserDefaults.standard.synchronize()
    }
    
    private func lastAPICallDifferenceInHours() -> Int {
        let lastAPITime = UserDefaults.standard.value(forKey: KeyConstants.AdvanceSearch.lastAPICallTime)
        let currentTime = Date().currentTimeMillis()
        let time1 = Date(timeIntervalSince1970: lastAPITime as? TimeInterval ?? 0)
        let time2 = Date(timeIntervalSince1970: TimeInterval(currentTime))
        let difference = Calendar.current.dateComponents([.second], from: time1, to: time2)
        let duration = (difference.second ?? 0).msToSeconds
        let hours = duration.secondsToHours
        return hours
    }
}

// MARK: - Advance Search
extension SearchViewModel {
    func loadAppConfigurationsForSearch() {
        let repository = ApplicationBootstrap.shared().repository
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        guard let accountIdentifier = accountService?.activeAccount?.identifier else { return }
        if let data = DiskService.getAdvanceSearchConfigurations(for: accountIdentifier) {
            // fetch configuration from local file stored in document directory
            parseAppConfiguration(for: data)
        } else {
            // load data from bundle
            loadConfigurationsFromAppBundle()
        }
        // self.loadConfigurationFromServer() // commented because we do not have any API for now.
    }
    
    private func loadConfigurationsFromAppBundle() {
        if let fileUrl = Bundle.main.url(forResource: KeyConstants.AdvanceSearch.configFile, withExtension: KeyConstants.AdvanceSearch.configFileExtension) {
            do {
                let data = try Data(contentsOf: fileUrl, options: [])
                self.saveConfiguartionLocally(for: data)
                parseAppConfiguration(for: data)
            } catch let error {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    private func parseAppConfiguration(for data: Data?) {
        if let json = data {
            do {
                let decoded = try JSONDecoder().decode(AlfrescoContent.SearchConfigModel.self, from: json)
                self.searchFilterObservable.value = decoded.search
            } catch {
                AlfrescoLog.error(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Load configuration from server and store locally
    func loadConfigurationFromServer() {
        if self.isAdvanceSearchFiltersAllowedFromServer() {
            self.searchModel.getAdvanceSearchConfigurationFromServer { (configuration, data)  in
                guard let configuration = configuration else { return }
                self.saveConfiguartionLocally(for: data)
                self.searchFilterObservable.value = configuration.search
            }
        }
    }
    
    private func saveConfiguartionLocally(for data: Data?) {
        let repository = ApplicationBootstrap.shared().repository
        let accountService = repository.service(of: AccountService.identifier) as? AccountService
        guard let accountIdentifier = accountService?.activeAccount?.identifier else { return }
        DiskService.saveAdvanceSearchConfigurations(for: accountIdentifier, and: data)
    }
    
    private func isChipSelected() -> Bool {
        let categories = self.getAllCategoriesForSelectedFilter()
        for counter in 0 ..< categories.count {
            let selectedValue = categories[counter].component?.settings?.selectedValue ?? ""
            if !selectedValue.isEmpty {
                return true
            }
        }
        return false
    }
}

// MARK: - Advance Search Categories
extension SearchViewModel {
    func getAllCategoriesForSelectedFilter() -> [SearchCategories] {
        let searchFilters = self.searchFilters
        if let selectedSearchFilter = self.searchModel.selectedSearchFilter {
            if let object = searchFilters.enumerated().first(where: {$0.element.name == selectedSearchFilter.name}) {
                let index = object.offset
                return searchFilters[index].categories
            }
        }
        return []
    }
    
    func getSelectedCategory() -> SearchCategories? {
        let categories = self.getAllCategoriesForSelectedFilter()
        let index = self.getIndexOfSelectedCategory()
        if index >= 0 {
            return categories[index]
        }
        return nil
    }
    
    func getSelectedCategory(for selector: ComponentType?) -> SearchCategories? {
        let categories = self.getAllCategoriesForSelectedFilter()
        if let selector = selector {
            if let object = categories.enumerated().first(where: {$0.element.component?.selector == selector.rawValue}) {
                let index = object.offset
                return categories[index]
            }
        }
        return nil
    }
    
    func getIndexOfSelectedCategory() -> Int {
        let categories = self.getAllCategoriesForSelectedFilter()
        if let selectedCategory = self.selectedCategory {
            if let object = categories.enumerated().first(where: {$0.element.searchID == selectedCategory.searchID}) {
                return object.offset
            }
        }
        return -1
    }
    
    func getIndexOfSelectedChip(for chips: [SearchChipItem]) -> Int {
        if let selectedChip = self.selectedChip {
            if let object = chips.enumerated().first(where: {$0.element.componentType == selectedChip.componentType && $0.element.name == selectedChip.name}) {
                return object.offset
            }
        }
        return -1
    }
}

// MARK: - Reset Advance Search
extension SearchViewModel {
    func getSelectedFilterIndex() -> Int {
        let searchFilters = self.searchFilters
        if let selectedSearchFilter = self.searchModel.selectedSearchFilter {
            if let object = searchFilters.enumerated().first(where: {$0.element.name == selectedSearchFilter.name}) {
                let index = object.offset
                return index
            }
        }
        return -1
    }
    
    func resetAdvanceSearch() {
        var categories = self.getAllCategoriesForSelectedFilter()
        for counter in 0 ..< categories.count {
            let category = categories[counter]
            category.component?.settings?.selectedValue = nil
            categories[counter] = category
        }
        
        /// update category array
        let index = self.getSelectedFilterIndex()
        if index >= 0 {
            searchFilters[index].categories = categories
        }
        
        /// reset selected components
        selectedCategory = nil
        selectedChip = nil
    }
    
    func isSearchChipsHasSelectedValue() -> Bool {
        if self.searchModel.searchChips.first(where: {!($0.selectedValue).isEmpty}) != nil {
            return true
        }
        return false
    }
}

// MARK: - Facet Filters
extension SearchViewModel {
    func getFacetFields() -> FacetFields? {
        let searchFilters = self.searchFilters
        if let selectedSearchFilter = self.searchModel.selectedSearchFilter {
            if let object = searchFilters.enumerated().first(where: {$0.element.name == selectedSearchFilter.name}) {
                let index = object.offset
                return searchFilters[index].facetFields
            }
        }
        return nil
    }
    
    func getFacetQueries() -> FacetQueries? {
        let searchFilters = self.searchFilters
        if let selectedSearchFilter = self.searchModel.selectedSearchFilter {
            if let object = searchFilters.enumerated().first(where: {$0.element.name == selectedSearchFilter.name}) {
                let index = object.offset
                return searchFilters[index].facetQueries
            }
        }
        return nil
    }
    
    func getFacetIntervals() -> FacetIntervals? {
        let searchFilters = self.searchFilters
        if let selectedSearchFilter = self.searchModel.selectedSearchFilter {
            if let object = searchFilters.enumerated().first(where: {$0.element.name == selectedSearchFilter.name}) {
                let index = object.offset
                return searchFilters[index].facetIntervals
            }
        }
        return nil
    }
    
    func isFacetsFieldsEmpty() -> Bool {
        if facetFields.isEmpty {
            return true
        }
        return false
    }
    
    func isFacetsQueriesEmpty() -> Bool {
        if facetQueries.isEmpty {
            return true
        }
        return false
    }
    
    func isFacetsIntervalsEmpty() -> Bool {
        if facetIntervals.isEmpty {
            return true
        }
        return false
    }

    // MARK: - Selected Facet Field
    func getSelectedFacetField(for name: String) -> SearchFacetFields? {
        if let object = self.facetFields.enumerated().first(where: {NSLocalizedString($0.element.label ?? "", comment: "") == name}) {
            let index = object.offset
            return facetFields[index]
        }
        return nil
    }
    
    // MARK: - Selected Facet Interval
    func getSelectedFacetInterval(for name: String) -> SearchFacetIntervals? {
        if let object = self.facetIntervals.enumerated().first(where: {NSLocalizedString($0.element.label ?? "", comment: "") == name}) {
            let index = object.offset
            return facetIntervals[index]
        }
        return nil
    }
    
    // MARK: Updated Facet Field Options
    func isFacetChipsHasSelectedValue() -> Bool {
        if self.searchModel.searchChips.first(where: {!($0.selectedValue).isEmpty && ($0.componentType == .facetField || $0.componentType == .facetQuery || $0.componentType == .facetInterval)}) != nil {
            return true
        }
        return false
    }
    
    func getUpdatedFacetFields(for newFacetFields: [SearchFacetFields]) -> [SearchFacetFields] {
        var oldFacetIFields = self.facetFields
        let difference = newFacetFields
            .filter({ currentObject in
                !(oldFacetIFields
                    .contains(where: { $0.label == currentObject.label }))
            })

        // Step1: Check if there are some new chips, which needs to be added
        if !difference.isEmpty {
            oldFacetIFields.append(contentsOf: difference)
        }
        
        for field in newFacetFields {
            let newLabel = field.label
            let newBuckets = field.buckets
            var tempNewBuckets = [Buckets]()

            // Step 2: Get index of object from old fields which matches object from new fields
            if let object = oldFacetIFields.enumerated().first(where: {$0.element.label == newLabel}) {
                let indexOfChip = object.offset
                
                var oldBuckets = [Buckets]()
                if self.isFacetChipsHasSelectedValue() == true {
                    oldBuckets = oldFacetIFields[indexOfChip].buckets
                }

                // Step 3: If old buckets has value which are in new buckts array, just replace the old values from the new one
                for bucket in newBuckets {
                    let newBucketLabel = bucket.label
                    if let bucketObject = oldBuckets.enumerated().first(where: {$0.element.label == newBucketLabel}) {
                        oldBuckets[bucketObject.offset] = bucket
                        tempNewBuckets.append(bucket)
                    }
                }
                
                // Step 4: Check for some values in bucket array which are totally new and not available in old bucket array. If there are values, append them also in the old buckets. Now old bucket array has all the values i.e. old bucket = prev. old bucket + new bucket
                
                if self.isFacetChipsHasSelectedValue() == false {
                    let arrayRemainingBuckets = newBuckets.filter { !tempNewBuckets.contains($0) }
                    oldBuckets.append(contentsOf: arrayRemainingBuckets)
                }
            
                // Step 5: Check for non matching values in old bucket array with the new bucket. If we have values for that, make the old bucket count to zero i.e. there is no result associated with that bucket option
                let arrayVoidBuckets = oldBuckets.filter { !newBuckets.contains($0) }
                for bucket in arrayVoidBuckets {
                    let voidBucketLabel = bucket.label
                    if let bucketObject = oldBuckets.enumerated().first(where: {$0.element.label == voidBucketLabel}) {
                        oldBuckets[bucketObject.offset].count = "0"
                    }
                }
                
                // Step 6: Update the bucket in the main fields array
                oldFacetIFields[indexOfChip].buckets = oldBuckets
            }
        }
        
        // Step 7: Return the final result
        return oldFacetIFields
    }
    
    // MARK: Updated Facet Interval Options
    func getUpdatedFacetIntervals(for newFacetIntervals: [SearchFacetIntervals]) -> [SearchFacetIntervals] {
        var oldFacetIntervals = self.facetIntervals
        let difference = newFacetIntervals
            .filter({ currentObject in
                !(oldFacetIntervals
                    .contains(where: { $0.label == currentObject.label }))
            })

        // Step1: Check if there are some new chips, which needs to be added
        if !difference.isEmpty {
            oldFacetIntervals.append(contentsOf: difference)
        }
        
        for interval in newFacetIntervals {
            let newLabel = interval.label
            let newBuckets = interval.buckets
            var tempNewBuckets = [Buckets]()

            // Step 2: Get index of object from old intervals which matches object from new interval
            if let object = oldFacetIntervals.enumerated().first(where: {$0.element.label == newLabel}) {
                let indexOfChip = object.offset
                var oldBuckets = [Buckets]()
                if self.isFacetChipsHasSelectedValue() == true {
                    oldBuckets = oldFacetIntervals[indexOfChip].buckets
                }
                                
                // Step 3: If old buckets has value which are in new buckts array, just replace the old values from the new one
                for bucket in newBuckets {
                    let newBucketLabel = bucket.label
                    if let bucketObject = oldBuckets.enumerated().first(where: {$0.element.label == newBucketLabel}) {
                        oldBuckets[bucketObject.offset] = bucket
                        tempNewBuckets.append(bucket)
                    }
                }
                
                // Step 4: Check for some values in bucket array which are totally new and not available in old bucket array. If there are values, append them also in the old buckets. Now old bucket array has all the values i.e. old bucket = prev. old bucket + new bucket
                if self.isFacetChipsHasSelectedValue() == false {
                    let arrayRemainingBuckets = newBuckets.filter { !tempNewBuckets.contains($0) }
                    oldBuckets.append(contentsOf: arrayRemainingBuckets)
                }
            
                // Step 5: Check for non matching values in old bucket array with the new bucket. If we have values for that, make the old bucket count to zero i.e. there is no result associated with that bucket option
                let arrayVoidBuckets = oldBuckets.filter { !newBuckets.contains($0) }
                for bucket in arrayVoidBuckets {
                    let voidBucketLabel = bucket.label
                    if let bucketObject = oldBuckets.enumerated().first(where: {$0.element.label == voidBucketLabel}) {
                        oldBuckets[bucketObject.offset].count = "0"
                    }
                }
                
                // Step 6: Update the bucket in the main interval array
                oldFacetIntervals[indexOfChip].buckets = oldBuckets
            }
        }
        
        // Step 7: Return the final result
        return oldFacetIntervals
    }
    
    // MARK: Updated Facet Queries
    func getUpdatedFacetQueries(for newFacetQueries: [SearchFacetQueries]) -> [SearchFacetQueries] {
        var oldFacetQueries = self.facetQueries
        var tempNewFacetQueries = [SearchFacetQueries]()
        let difference = newFacetQueries
            .filter({ currentObject in
                !(oldFacetQueries
                    .contains(where: { $0.label == currentObject.label }))
            })

        // Step1: Check if there are some new chips, which needs to be added
        if !difference.isEmpty {
            oldFacetQueries.append(contentsOf: difference)
        }
        
        for query in newFacetQueries {
            let newQueryLabel = query.label
            if let object = oldFacetQueries.enumerated().first(where: {$0.element.label == newQueryLabel}) {
                oldFacetQueries[object.offset] = query
                tempNewFacetQueries.append(query)
            }
        }
        
        let arrayRemainingQuereies = newFacetQueries.filter { !tempNewFacetQueries.contains($0) }
        oldFacetQueries.append(contentsOf: arrayRemainingQuereies)
        
        let arrayVoidQueries = oldFacetQueries.filter { !newFacetQueries.contains($0) }
        for query in arrayVoidQueries {
            let voidQueryLabel = query.label
            if let bucketObject = oldFacetQueries.enumerated().first(where: {$0.element.label == voidQueryLabel}) {
                oldFacetQueries[bucketObject.offset].count = 0
            }
        }
        
        return oldFacetQueries
    }
}
