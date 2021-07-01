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

struct ModeSelectorEntry {
    let entryName: String
}

struct ModeSelectorControlSyle {
    let selectedOptionColor: UIColor
    let optionColor: UIColor
    let optionFont: UIFont
    let optionBackgroundColor: UIColor
}

protocol ModeSelectorControlDelegate: AnyObject {
    func didChangeSelection(to currentSelection: Int)
}

class ModeSelectorControl: UIControl {
    var entryPadding = 45
    weak var delegate: ModeSelectorControlDelegate?

    private(set) var currentSelection: Int = 0

    private let scrollView = UIScrollView()
    private var sliderLabelEntries: [UILabel] = []
    private var sliderButtonEntries: [UIButton] = []
    private var sliderStyle: ModeSelectorControlSyle =
        ModeSelectorControlSyle(selectedOptionColor: .green,
                                optionColor: .black,
                                optionFont: .systemFont(ofSize: 14),
                                optionBackgroundColor: .white)

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.backgroundColor = .clear
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
        scrollView.contentSize = self.frame.size

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: self.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.heightAnchor),
        ])
    }

    // MARK: - Public interface

    func addSlider(entries: ModeSelectorEntry...) {
        var previousEntryViewFrame: CGRect?

        for (index, entry) in entries.enumerated() {
            var entryFrame = CGRect(x: 0,
                                    y: 0,
                                    width: self.frame.width,
                                    height: self.frame.height)
            let sliderEntryView = PassthroughView(frame: entryFrame)
            let entryLabel = UILabel()
            let button = UIButton(frame: entryLabel.frame)
            button.tag = index
            button.accessibilityIdentifier = "cameraSlideButton\(index)"
            button.addTarget(self, action: #selector(handleTap(_:)),
                             for: .touchUpInside)

            entryLabel.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false

            entryLabel.textAlignment = .center
            entryLabel.text = entry.entryName

            sliderLabelEntries.append(entryLabel)
            sliderButtonEntries.append(button)
            sliderEntryView.addSubview(button)
            sliderEntryView.addSubview(entryLabel)
            scrollView.addSubview(sliderEntryView)

            if let labelTitle = sliderLabelEntries[index].text {
                let labelWidth = (labelTitle as NSString).size(withAttributes: [ .font: sliderStyle.optionFont ]).width
                entryFrame.size.width = labelWidth

                if index > 0, let previousEntryViewFrame = previousEntryViewFrame {
                    entryFrame.origin.x = previousEntryViewFrame.origin.x +
                        previousEntryViewFrame.size.width +
                        CGFloat(entryPadding)
                }

                previousEntryViewFrame = entryFrame
                sliderEntryView.frame = entryFrame
            }

            NSLayoutConstraint.activate([
                entryLabel.centerXAnchor.constraint(equalTo: sliderEntryView.centerXAnchor),
                entryLabel.centerYAnchor.constraint(equalTo: sliderEntryView.centerYAnchor),
                button.centerYAnchor.constraint(equalTo: sliderEntryView.centerYAnchor),
                button.leadingAnchor.constraint(equalTo: entryLabel.leadingAnchor, constant: -16.0),
                button.trailingAnchor.constraint(equalTo: entryLabel.trailingAnchor, constant: 16.0)
            ])
        }
    }

    func update(style: ModeSelectorControlSyle) {
        sliderStyle = style
        applyCurrentStyle()
    }

    // MARK: - Private interface

    private func applyCurrentStyle() {
        for (index, entry) in sliderLabelEntries.enumerated() {
            entry.textColor = index == currentSelection
                ? sliderStyle.selectedOptionColor : sliderStyle.optionColor
            entry.font = sliderStyle.optionFont
            entry.sizeToFit()
        }
        for entry in sliderButtonEntries {
            entry.backgroundColor = sliderStyle.optionBackgroundColor
            entry.layer.cornerRadius = entry.bounds.height / 2.0
            entry.layer.masksToBounds = true
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
            if currentSelection < sliderLabelEntries.count - 1 {
                currentSelection += 1
            } else {
                return
            }
        default: break
        }

        scrollToCurrentSelection(animated: true)
    }

    @objc private func handleTap(_ sender: UIButton) {
        currentSelection = sender.tag
        scrollToCurrentSelection(animated: true)
    }

    private func scrollToCurrentSelection(animated: Bool) {
        if let currentSelectionParentView = sliderLabelEntries[currentSelection].superview {
            let currentSelectionPoint = CGPoint(x: currentSelectionParentView.center.x - self.frame.width / 2,
                                                y: scrollView.contentOffset.y)
            scrollView.setContentOffset(currentSelectionPoint, animated: animated)
            applyCurrentStyle()

            delegate?.didChangeSelection(to: currentSelection)
        }
    }
}

class PassthroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
