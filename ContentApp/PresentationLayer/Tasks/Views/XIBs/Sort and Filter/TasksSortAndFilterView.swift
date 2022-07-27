//
// Copyright (C) 2005-2022 Alfresco Software Limited.
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
import DropDown

protocol TasksSortAndFilterDelegate {
    func didSelectTaskFilter(_ filter: TasksFilters)
}

class TasksSortAndFilterView: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var filterButton: UIButton!
    var currentTheme: PresentationTheme?
    lazy var viewModel = TasksSortAndFilterViewModel()
    lazy var dropDown = DropDown()
    var deleagte: TasksSortAndFilterDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        viewModel.getFilters()
        setupDropDownView()
        buildDropDownDataSource()
    }
    
    func applyTheme(_ currentTheme: PresentationTheme?) {
        guard let currentTheme = currentTheme else { return }
        self.currentTheme = currentTheme
        backgroundColor = currentTheme.surfaceColor
        filterLabel.applyStyleBody1OnSurface(theme: currentTheme)
        filterLabel.lineBreakMode = .byTruncatingTail
        dropDown.backgroundColor = currentTheme.surfaceColor
        dropDown.selectionBackgroundColor = currentTheme.primary15T1Color
        dropDown.textColor = currentTheme.onSurfaceColor
        dropDown.selectedTextColor = currentTheme.onSurfaceColor
        
//        subtitle.applyStyleCaptionOnSurface60(theme: currentTheme)
//        subtitle.lineBreakMode = .byTruncatingHead
//        iconImageView.tintColor = currentTheme.onSurface60Color
//        moreButton.tintColor = currentTheme.onSurface60Color
//        syncStatusImageView.tintColor = currentTheme.onSurface60Color
//        disableFiles(isDisable: isDisable)
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        AlfrescoLog.debug("filter button action")
        dropDown.show()
    }
}

// MARK: - Drop Down
extension TasksSortAndFilterView {
    func setupDropDownView() {
        dropDown.anchorView = filterView
        dropDown.bottomOffset = CGPoint(x: 0, y: (dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.cornerRadius = 6
        dropDown.width = 200
    }
    
    func buildDropDownDataSource() {
        let searchFilters = viewModel.localizedFilterNames
        dropDown.localizationKeysDataSource = searchFilters
        dropDown.reloadAllComponents()
        dropDown.selectionAction = { (index: Int, item: String) in
            self.viewModel.filters = TasksFilters.updateSelectedFilter(at: index, for: self.viewModel.filters)
            self.setFilterDetails()
        }
    }
    
    func setFilterDetails() {
        if let filter = self.viewModel.selectedFilter {
            filterLabel.text = filter.name
            deleagte?.didSelectTaskFilter(filter)
        }
    }
}
