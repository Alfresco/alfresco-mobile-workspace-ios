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

struct CameraSliderEntry {
    let entryName: String?
}

struct CameraSliderControlSyle {
    let selectedOptionColor: UIColor?
    let optionColor: UIColor?
    let optionFont: UIFont?
}

protocol CameraSliderControlDelegate: class {
    func didChangeSelection(to currentSelection: Int)
}

class CameraSliderControl: UIControl {
    var entryPadding = 75
    weak var delegate: CameraSliderControlDelegate?

    private(set) var currentSelection: Int = 0

    private let scrollView = UIScrollView()
    private var sliderEntries: [UILabel] = []
    private var sliderStyle: CameraSliderControlSyle =
        CameraSliderControlSyle(selectedOptionColor: .green,
                                optionColor: .black,
                                optionFont: .systemFont(ofSize: 14))

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false

        self.addSubview(scrollView)

        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                              action: #selector(handleSwipe(_:)))
        rightSwipeGestureRecognizer.direction = .right
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self,
                                                              action: #selector(handleSwipe(_:)))
        leftSwipeGestureRecognizer.direction = .left

        self.addGestureRecognizer(rightSwipeGestureRecognizer)
        self.addGestureRecognizer(leftSwipeGestureRecognizer)
    }

    override func layoutSubviews() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: self.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
    }

    // MARK: - Public interface

    func addSlider(entries: CameraSliderEntry...) {
        let contentWidth = scrollView.contentSize.width + CGFloat(entryPadding) * CGFloat(entries.count)
        scrollView.contentSize = CGSize(width: contentWidth,
                                        height: self.frame.height)
        for (index, entry) in entries.enumerated() {
            let entryFrame = CGRect(x: CGFloat(entryPadding) * CGFloat(index),
                                          y: 0,
                                          width: self.frame.width,
                                          height: self.frame.height)
            let sliderEntryView = PassthroughView(frame: entryFrame)
            let entryLabel = UILabel()
            let button = UIButton(frame: entryLabel.frame)
            button.tag = index
            button.addTarget(self, action: #selector(handleTap(_:)),
                             for: .touchUpInside)

            entryLabel.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false

            entryLabel.textAlignment = .center
            entryLabel.text = entry.entryName

            sliderEntries.append(entryLabel)
            sliderEntryView.addSubview(entryLabel)
            sliderEntryView.addSubview(button)
            scrollView.addSubview(sliderEntryView)

            NSLayoutConstraint.activate([
                entryLabel.centerXAnchor.constraint(equalTo: sliderEntryView.centerXAnchor),
                entryLabel.centerYAnchor.constraint(equalTo: sliderEntryView.centerYAnchor),
                button.centerXAnchor.constraint(equalTo: sliderEntryView.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: sliderEntryView.centerYAnchor)
            ])
        }
    }

    func updateStyle(style: CameraSliderControlSyle) {
        sliderStyle = style
        applyCurrentStyle()
    }

    // MARK: - Private interface

    private func applyCurrentStyle() {
        for (index, entry) in sliderEntries.enumerated() {
            entry.textColor = index == currentSelection ? sliderStyle.selectedOptionColor : sliderStyle.optionColor
            entry.font = sliderStyle.optionFont
            entry.sizeToFit()
        }
    }

    @objc private func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .right:
            if currentSelection > 0 {
                currentSelection -= 1
            } else {
                return
            }
        case .left:
            if currentSelection < sliderEntries.count - 1 {
                currentSelection += 1
            } else {
                return
            }
        default:
            break
        }

        scrollToCurrentSelection()
    }

    @objc private func handleTap(_ sender: UIButton) {
        currentSelection = sender.tag
        scrollToCurrentSelection()
    }

    private func scrollToCurrentSelection() {
        let currentSelectionPoint = CGPoint(x: CGFloat(currentSelection * entryPadding),
                                            y: scrollView.contentOffset.y)
        scrollView.setContentOffset(currentSelectionPoint, animated: true)
        applyCurrentStyle()

        delegate?.didChangeSelection(to: currentSelection)
    }
}

class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}