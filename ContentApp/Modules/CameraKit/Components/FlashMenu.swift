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

struct FlashMenuStyle {
    var optionTintColor: UIColor
    var optionFont: UIFont
    var optionColor: UIColor
    var backgroundColor: UIColor
    var autoFlashText: String
    var onFlashText: String
    var offFlashText: String
}

protocol FlashMenuDelegate: class {
    func selected(flashMode: FlashMode)
}

class FlashMenu: UIView {
    
    private var style = FlashMenuStyle(optionTintColor: .black,
                                       optionFont: .systemFont(ofSize: 14),
                                       optionColor: .black,
                                       backgroundColor: UIColor.gray.withAlphaComponent(0.6),
                                       autoFlashText: "Auto",
                                       onFlashText: "On",
                                       offFlashText: "Off")
    weak var delegate: FlashMenuDelegate?
    private let autoFlashButton = UIButton()
    private let onFlashButton = UIButton()
    private let offFlashButton = UIButton()
    
    // MARK: - Public Methods
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        layer.cornerRadius = 8.0
        translatesAutoresizingMaskIntoConstraints = false
        
        addButtons()
    }
    
    func addButtons() {
        autoFlashButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        autoFlashButton.translatesAutoresizingMaskIntoConstraints = false
        autoFlashButton.tag = 0
        autoFlashButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        autoFlashButton.contentHorizontalAlignment = .left
        autoFlashButton.accessibilityIdentifier = "autoFlashButton"
        addSubview(autoFlashButton)
        
        onFlashButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        onFlashButton.translatesAutoresizingMaskIntoConstraints = false
        onFlashButton.tag = 1
        onFlashButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        onFlashButton.contentHorizontalAlignment = .left
        onFlashButton.accessibilityIdentifier = "onFlashButton"
        addSubview(onFlashButton)
        
        offFlashButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 0)
        offFlashButton.translatesAutoresizingMaskIntoConstraints = false
        offFlashButton.tag = 2
        offFlashButton.addTarget(self, action: #selector(handleTap(_:)), for: .touchUpInside)
        offFlashButton.contentHorizontalAlignment = .left
        offFlashButton.accessibilityIdentifier = "offFlashButton"
        addSubview(offFlashButton)
        
        NSLayoutConstraint.activate([
            autoFlashButton.heightAnchor.constraint(equalToConstant: 48.0),
            autoFlashButton.topAnchor.constraint(equalTo: topAnchor, constant: 8.0),
            autoFlashButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.0),
            autoFlashButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
            autoFlashButton.bottomAnchor.constraint(equalTo: onFlashButton.topAnchor, constant: 0.0),

            onFlashButton.heightAnchor.constraint(equalTo: autoFlashButton.heightAnchor),
            onFlashButton.widthAnchor.constraint(equalTo: autoFlashButton.widthAnchor),
            onFlashButton.centerXAnchor.constraint(equalTo: autoFlashButton.centerXAnchor),
            onFlashButton.bottomAnchor.constraint(equalTo: offFlashButton.topAnchor, constant: 0.0),
            
            offFlashButton.heightAnchor.constraint(equalTo: autoFlashButton.heightAnchor),
            offFlashButton.widthAnchor.constraint(equalTo: autoFlashButton.widthAnchor),
            offFlashButton.centerXAnchor.constraint(equalTo: autoFlashButton.centerXAnchor),
            offFlashButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8.0)
        ])
    }
    
    override func layoutSubviews() {
        addButtons()
        applyCurrentStyle()
    }
    
    func update(style: FlashMenuStyle) {
        self.style = style
        applyCurrentStyle()
    }
    
    @objc private func handleTap(_ sender: UIButton) {
        switch sender.tag {
        case 0: delegate?.selected(flashMode: .auto)
        case 1: delegate?.selected(flashMode: .on)
        case 2: delegate?.selected(flashMode: .off)
        default: break
        }
    }
    
    // MARK: - Private Methods
    
    private func applyCurrentStyle() {
        backgroundColor = style.backgroundColor
        
        autoFlashButton.setTitle(style.autoFlashText, for: .normal)
        autoFlashButton.setImage(FlashMode.auto.icon, for: .normal)
        autoFlashButton.titleLabel?.font = style.optionFont
        autoFlashButton.setTitleColor(style.optionColor, for: .normal)
        autoFlashButton.tintColor = style.optionTintColor
        
        onFlashButton.setTitle(style.onFlashText, for: .normal)
        onFlashButton.setImage(FlashMode.on.icon, for: .normal)
        onFlashButton.titleLabel?.font = style.optionFont
        onFlashButton.setTitleColor(style.optionColor, for: .normal)
        onFlashButton.tintColor = style.optionTintColor
        
        offFlashButton.setTitle(style.offFlashText, for: .normal)
        offFlashButton.setImage(FlashMode.off.icon, for: .normal)
        offFlashButton.titleLabel?.font = style.optionFont
        offFlashButton.setTitleColor(style.optionColor, for: .normal)
        offFlashButton.tintColor = style.optionTintColor
    }
}
