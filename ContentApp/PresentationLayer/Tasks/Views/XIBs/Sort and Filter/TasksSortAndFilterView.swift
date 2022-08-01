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
import MaterialComponents.MaterialChips
import MaterialComponents.MaterialChips_Theming
import MaterialComponents.MDCChipView
import MaterialComponents.MDCChipView_MaterialTheming

class TasksSortAndFilterView: UIView {

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var chipsCollectionView: UICollectionView!
    @IBOutlet weak var resetFilterButton: UIButton!
    var currentTheme: PresentationTheme?
    lazy var viewModel = TasksSortAndFilterViewModel()
    var coordinatorServices: CoordinatorServices?
    var navigationController: UINavigationController?
    private let textChipMaxCharacters = 30
    private let textChipMaxPrefix = 5
    private let textChipMaxSufffix = 5
    private let chipSearchCellMinimWidth: CGFloat = 52.0
    private let chipSearchCellMinimHeight: CGFloat = 32.0

    override func awakeFromNib() {
        super.awakeFromNib()
        addChipsCollectionViewFlowLayout()
        chipsCollectionView.dataSource = self
        chipsCollectionView.delegate = self
        addAccessibility()
    }
    
    func addAccessibility() {
        resetFilterButton.accessibilityLabel = LocalizationConstants.Accessibility.resetFilters
        resetFilterButton.accessibilityTraits = .button
    }
    
    func applyTheme(_ currentTheme: PresentationTheme?, coordinatorServices: CoordinatorServices?, navigationController: UINavigationController?) {
        
        guard let currentTheme = currentTheme, let coordinatorServices = coordinatorServices, let navigationController = navigationController else { return }
        self.currentTheme = currentTheme
        self.coordinatorServices = coordinatorServices
        self.navigationController = navigationController
        backgroundColor = currentTheme.surfaceColor
        
        baseView.backgroundColor = currentTheme.surfaceColor
        resetFilterButton.backgroundColor = currentTheme.surfaceColor
        resetFilterButton.tintColor = currentTheme.onSurfaceColor
        resetFilterButton.accessibilityIdentifier = "searchResetButton"
        chipsCollectionView.reloadData()
    }
    
    func buildDataSource() {
        viewModel.loadFiltersFromAppBundle { [weak self] isDone in
            guard let sSelf = self else { return }
            sSelf.chipsCollectionView.reloadData()
        }
    }
    
    @IBAction func resetFilterButtonAction(_ sender: Any) {        
        viewModel.resetChipsAction()
        chipsCollectionView.reloadData()
        AnalyticsManager.shared.taskFilters(name: Event.Action.taskFilterReset.rawValue)
    }
    
    func addChipsCollectionViewFlowLayout() {
        chipsCollectionView.register(MDCChipCollectionViewCell.self,
                                     forCellWithReuseIdentifier: "MDCChipCollectionViewCell")
        chipsCollectionView.allowsMultipleSelection = false
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        collectionViewFlowLayout.scrollDirection = .horizontal
        chipsCollectionView.collectionViewLayout = collectionViewFlowLayout
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension TasksSortAndFilterView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.chips.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let reuseIdentifier = String(describing: MDCChipCollectionViewCell.self)
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                         for: indexPath) as? MDCChipCollectionViewCell {
            let chip = viewModel.chips[indexPath.row]
            let selectedValue = chip.selectedValue ?? ""
            let name = chip.name
            var chipSelectedValue = ""
            if selectedValue.isEmpty {
                cell.chipView.titleLabel.text = name
            } else {
                chipSelectedValue = getChipSelectedValue(for: selectedValue)
                cell.chipView.titleLabel.text = chipSelectedValue
            }
            cell.chipView.isSelected = chip.selected
            if chip.selected {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .top)
                cell.isSelected = true
            }
            
            if let themeService = coordinatorServices?.themingService {
                if chip.selected {
                    let scheme = themeService.containerScheming(for: .searchChipSelected)
                    let backgroundColor = themeService.activeTheme?.primary15T1Color
                    
                    cell.chipView.applyOutlinedTheme(withScheme: scheme)
                    cell.chipView.setBackgroundColor(backgroundColor, for: .selected)
                } else {
                    let scheme = themeService.containerScheming(for: .searchChipUnselected)
                    let backgroundColor = themeService.activeTheme?.surfaceColor
                    let borderColor = themeService.activeTheme?.onSurface15Color
                    
                    cell.chipView.applyOutlinedTheme(withScheme: scheme)
                    cell.chipView.setBackgroundColor(backgroundColor, for: .normal)
                    cell.chipView.setBorderColor(borderColor, for: .normal)
                }
            }
            
            cell.accessibilityIdentifier = name
            cell.chipView.accessibilityLabel = name
            cell.chipView.accessibilityValue = chipSelectedValue
            cell.chipView.accessibilityIdentifier = chip.accessibilityIdentifier ?? ""
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    func getChipSelectedValue(for value: String) -> String {
        let selectedValueArray = value.components(separatedBy: ",")
        if selectedValueArray.count > 1 {
            let firstValue = selectedValueArray[0]
            let count = selectedValueArray.count - 1
            if firstValue.count > textChipMaxCharacters {
                let prefixString = String(firstValue.prefix(textChipMaxPrefix))
                let suffixString = String(firstValue.suffix(textChipMaxSufffix))
                let shortString = String(format: "%@ ... %@", prefixString, suffixString)
                return String(format: "%@ + %d", shortString, count)
            } else {
                return String(format: "%@ + %d", firstValue, count)
            }
        } else if value.count > textChipMaxCharacters {
            let prefixString = String(value.prefix(textChipMaxCharacters))
            return String(format: "%@...", prefixString)
        } else {
            return value
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        self.selectChipCollectionCell(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let chip = viewModel.chips[indexPath.row]
        let name = chip.name ?? ""
        let selectedValue = chip.selectedValue ?? ""
        let text = selectedValue.isEmpty ? name : selectedValue
        let value = getChipSelectedValue(for: text)
        let width = getTextWidth(for: value)
        return CGSize(width: width,
                      height: chipSearchCellMinimHeight)
    }
    
    private func getTextWidth(for text: String) -> CGFloat {
        if let activeTheme = coordinatorServices?.themingService?.activeTheme {
            let font = activeTheme.captionTextStyle.font
            let fontAttributes = [NSAttributedString.Key.font: font]
            let size = (text as NSString).size(withAttributes: fontAttributes)
            let textWidth = size.width + 35.0
            let width = textWidth < chipSearchCellMinimWidth ? chipSearchCellMinimWidth : textWidth
            return width
        }
        return chipSearchCellMinimWidth
    }
    
    private func selectChipCollectionCell(for indexPath: IndexPath) {
        let chip = viewModel.chips[indexPath.row]
        chip.selected = true
        if let themeService = coordinatorServices?.themingService {
            let cell = chipsCollectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell

            let scheme = themeService.containerScheming(for: .searchChipSelected)
            let backgroundColor = themeService.activeTheme?.primary15T1Color

            cell?.chipView.applyOutlinedTheme(withScheme: scheme)
            cell?.chipView.setBackgroundColor(backgroundColor, for: .selected)
        }
        
        self.showSelectedComponent(for: chip, and: indexPath)
        self.viewModel.selectedChip = chip
        reloadChipCollectionWithoutScroll()
    }
    
    private func deSelectChipCollectionCell(for indexPath: IndexPath) {
        let chip = viewModel.chips[indexPath.row]
        chip.selected = false
        self.viewModel.selectedChip = chip
        if let themeService = coordinatorServices?.themingService {
            if let cell = chipsCollectionView.cellForItem(at: indexPath) as? MDCChipCollectionViewCell {
                let scheme = themeService.containerScheming(for: .searchChipUnselected)
                let backgroundColor = themeService.activeTheme?.surfaceColor
                let borderColor = themeService.activeTheme?.onSurface15Color

                cell.chipView.applyOutlinedTheme(withScheme: scheme)
                cell.chipView.setBackgroundColor(backgroundColor, for: .normal)
                cell.chipView.setBorderColor(borderColor, for: .normal)
            }
        }
    }
    
    func reloadChipCollectionWithoutScroll() {
        self.chipsCollectionView.reloadData()
    }
}

// MARK: - Filter Components Components
extension TasksSortAndFilterView {
    
    func showSelectedComponent(for chip: TaskChipItem, and indexPath: IndexPath) {
        
        if chip.componentType == .dateRange {
            showCalendarSelectorComponent(for: chip, and: indexPath)
        } else if chip.componentType == .radio {
            showListSelectorComponent(for: chip, and: indexPath)
        } else if chip.componentType == .text {
            showTextSelectorComponent(for: chip, and: indexPath)
        }
        
        // analytics
        var name = ""
        switch chip.componentType {
        case .dateRange:
            name = Event.Action.taskFilterDueDate.rawValue
        case .radio:
            name = Event.Action.taskFilterStatus.rawValue
        case .text:
            name = Event.Action.taskFilterTaskName.rawValue
        case nil:
            name = ""
        case .some(.none):
            name = ""
        }
        AnalyticsManager.shared.taskFilters(name: name)
    }
    
    // Calendar Component
    private func showCalendarSelectorComponent(for chip: TaskChipItem, and indexPath: IndexPath) {
      
        let viewController = SearchCalendarComponentViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.delegate = self
        viewController.coordinatorServices = coordinatorServices
        viewController.calendarViewModel.taskChip = chip
        viewController.taskFilterCallBack = { (selectedChip, isBackButtonTapped) in
            if isBackButtonTapped {
                 self.resetChip()
            } else if let selectedChip = selectedChip {
                self.updateChip(for: selectedChip, and: indexPath)
            }
        }
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
    }
    
    // Radio Component
    private func showListSelectorComponent(for chip: TaskChipItem, and indexPath: IndexPath) {
       
        let viewController = SearchListComponentViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.delegate = self
        viewController.coordinatorServices = coordinatorServices
        viewController.listViewModel.isRadioList = true
        viewController.listViewModel.taskChip = chip
        viewController.taskFilterCallBack = { (selectedChip, isBackButtonTapped) in
            if isBackButtonTapped {
                 self.resetChip()
            } else if let selectedChip = selectedChip {
                self.updateChip(for: selectedChip, and: indexPath)
            }
        }
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
    }
    
    //  Text Component
    private func showTextSelectorComponent(for chip: TaskChipItem, and indexPath: IndexPath) {
        let viewController = SearchTextComponentViewController.instantiateViewController()
        let bottomSheet = MDCBottomSheetController(contentViewController: viewController)
        bottomSheet.dismissOnDraggingDownSheet = false
        bottomSheet.delegate = self
        viewController.coordinatorServices = coordinatorServices
        viewController.textViewModel.taskChip = chip
        viewController.taskFilterCallBack = { (selectedChip, isBackButtonTapped) in
            if isBackButtonTapped {
                 self.resetChip()
            } else if let selectedChip = selectedChip {
                self.updateChip(for: selectedChip, and: indexPath)
            }
        }
        self.navigationController?.present(bottomSheet, animated: true, completion: nil)
    }
    
    func updateChip(for chip: TaskChipItem, and indexPath: IndexPath) {
        
        self.viewModel.chips[indexPath.row] = chip
        let selectedValue = self.viewModel.chips[indexPath.row].selectedValue ?? ""
        if !selectedValue.isEmpty {
            reloadChipCollectionWithoutScroll()
            // call api
        } else {
            reloadChipCollectionWithoutScroll()
            self.deSelectChipCollectionCell(for: indexPath)
            // call api
        }
    }
}

// MARK: - Bottom sheet delegate
extension TasksSortAndFilterView: MDCBottomSheetControllerDelegate {
    func bottomSheetControllerDidDismissBottomSheet(_ controller: MDCBottomSheetController) {
        self.resetChip()
    }
    
    func resetChip() {
        if let selectedChip = self.viewModel.selectedChip {
            if let index = self.viewModel.chips.firstIndex(where: {$0.chipId == selectedChip.chipId}) {
                let selectedValue = selectedChip.selectedValue ?? ""
                if selectedValue.isEmpty {
                    let indexPath = IndexPath(row: index, section: 0)
                    self.deSelectChipCollectionCell(for: indexPath)
                    reloadChipCollectionWithoutScroll()
                }
            }
        }
    }
}
