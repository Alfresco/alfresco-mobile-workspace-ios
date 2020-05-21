//
//  AdvancedSettingsViewController.swift
//  ContentApp
//
//  Created by Florin Baincescu on 21/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import UIKit

class AdvancedSettingsViewController: UIViewController {

    @IBOutlet weak var transportProtocolLabel: UILabel!
    @IBOutlet weak var settingsLabel: UILabel!
    @IBOutlet weak var authenticationLabel: UILabel!
    
    @IBOutlet weak var httpsLabel: UILabel!
    @IBOutlet weak var httpsSwitch: UISwitch!
    
    @IBOutlet weak var portTextField: UITextField!
    @IBOutlet weak var realmTextField: UITextField!
    @IBOutlet weak var clientIDTextField: UITextField!
    
    @IBOutlet weak var needHelpButton: UIButton!
    @IBOutlet weak var copyrightLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - IBAction
    
    @IBAction func httpsSwitchTapped(_ sender: UISwitch) {
    }
    
    @IBAction func needHelpButtonTapped(_ sender: UIButton) {
    }

}

extension AdvancedSettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
