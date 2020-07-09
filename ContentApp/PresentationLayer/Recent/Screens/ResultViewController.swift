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

protocol ResultScreenDelegate: class {
    func recentSearchTapped(string: String)
    func nodeListTapped(nodeList: ListNode)
}

class ResultViewController: UIViewController {

    @IBOutlet weak var resultNodescollectionView: UICollectionView!

    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListTitle: UILabel!
    @IBOutlet weak var emptyListSubtitle: UILabel!
    @IBOutlet weak var emptyListImageView: UIImageView!

    @IBOutlet weak var recentSearchesView: UIView!
    @IBOutlet weak var recentSearchesTitle: UILabel!
    @IBOutlet weak var recentSearchCollectionView: UICollectionView!

    weak var resultScreenDelegate: ResultScreenDelegate?
    var themingService: MaterialDesignThemingService?
    var activityIndicator: ActivityIndicatorView?
    var resultsNodes: [ListNode] = []
    var recentSearches: [String] = []

    var nodeHeighCell: CGFloat = 64.0
    var recentSearchHeighCell: CGFloat = 48.0

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        emptyListView.isHidden = true
        resultsNodes = []
        registerAlfrescoNodeCell()
        addLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addMaterialComponentsTheme()
        activityIndicator = ActivityIndicatorView(currentTheme: themingService?.activeTheme,
                                                  configuration: ActivityIndicatorConfiguration(title: LocalizationConstants.Search.searching,
                                                                                                radius: 12,
                                                                                                strokeWidth: 2,
                                                                                                cycleColors: [themingService?.activeTheme?.activityIndicatorSearchViewColor ?? .black]))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.isHidden = false
    }

    // MARK: - Public Helpers

    func updateDataSource(_ results: [ListNode]?) {
        if let results = results {
            resultsNodes = results
            emptyListView.isHidden = !results.isEmpty
            recentSearchesView.isHidden = true
        } else {
            resultsNodes = []
            emptyListView.isHidden = true
            recentSearchesView.isHidden = false
        }
        activityIndicator?.state = .isIdle
        resultNodescollectionView.reloadData()
    }

    func startLoading() {
        activityIndicator?.state = .isLoading
    }

    func updateRecentSearches(_ array: [String]) {
        recentSearchesTitle.text = (array.isEmpty) ? LocalizationConstants.Search.noRecentSearch : LocalizationConstants.Search.recentSearch
        recentSearches = array
        activityIndicator?.state = .isIdle
        recentSearchCollectionView.reloadData()
    }

    // MARK: - Helpers

    func registerAlfrescoNodeCell() {
        let identifier = String(describing: AlfrescoNodeCollectionViewCell.self)
        resultNodescollectionView?.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }

    func addLocalization() {
        emptyListTitle.text = LocalizationConstants.Search.title
        emptyListSubtitle.text = LocalizationConstants.Search.subtitle
        recentSearchesTitle.text = LocalizationConstants.Search.noRecentSearch
    }

    func addMaterialComponentsTheme() {
        guard let currentTheme = self.themingService?.activeTheme else { return }
        emptyListTitle.font = currentTheme.emptyListTitleLabelFont
        emptyListTitle.textColor = currentTheme.emptyListTitleLabelColor
        emptyListSubtitle.font = currentTheme.emptyListSubtitleLabelFont
        emptyListSubtitle.textColor = currentTheme.emptyListSubtitleLabelColor
        recentSearchesTitle.font = currentTheme.recentSearcheTitleLabelFont
        recentSearchesTitle.textColor = currentTheme.recentSearchesTitleLabelColor
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension ResultViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case recentSearchCollectionView:
            return recentSearches.count
        case resultNodescollectionView:
            return resultsNodes.count
        default: return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case resultNodescollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AlfrescoNodeCollectionViewCell.self),
                                                          for: indexPath) as? AlfrescoNodeCollectionViewCell
            cell?.node = resultsNodes[indexPath.row]
            cell?.applyThemingService(themingService?.activeTheme)
            return cell ?? UICollectionViewCell()
        case self.recentSearchCollectionView:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: RecentSearchCollectionViewCell.self),
                                                          for: indexPath) as? RecentSearchCollectionViewCell
            cell?.search = recentSearches[indexPath.row]
            cell?.applyThemingService(themingService?.activeTheme)
            return cell ?? UICollectionViewCell()
        default:
            return UICollectionViewCell()
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case recentSearchCollectionView:
            resultScreenDelegate?.recentSearchTapped(string: recentSearches[indexPath.row])
        case resultNodescollectionView:
            resultScreenDelegate?.nodeListTapped(nodeList: resultsNodes[indexPath.row])
        default: break
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case recentSearchCollectionView:
            return CGSize(width: self.view.bounds.width, height: recentSearchHeighCell)
        case resultNodescollectionView:
            return CGSize(width: self.view.bounds.width, height: nodeHeighCell)
        default:
            return CGSize(width: 0, height: 0)
        }
    }
}

// MARK: - Storyboard Instantiable

extension ResultViewController: StoryboardInstantiable { }
