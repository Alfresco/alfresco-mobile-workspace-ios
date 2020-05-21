//
//  ConnectViewController.swift
//  ContentApp
//
//  Created by Florin Baincescu on 20/05/2020.
//  Copyright © 2020 Florin Baincescu. All rights reserved.
//

import UIKit

class ConnectViewController: UIViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var connectTextField: UITextField!

    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var advancedSettingsButton: UIButton!
    @IBOutlet weak var needHelpButton: UIButton!

    @IBOutlet weak var copyrightLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBar()
    }

    // MARK: - IBActions

    @IBAction func connectButtonTapped(_ sender: UIButton) {

    }

    @IBAction func advancedSettingsButtonTapped(_ sender: UIButton) {
        self.performSegue(withIdentifier: kSegueIDAdvancedSettingsVCFromConnectVC, sender: nil)
    }

    @IBAction func needHelpButtonTapped(_ sender: UIButton) {

    }

    // MARK: - Helpers

    func hideNavigationBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case kSegueIDAdvancedSettingsVCFromConnectVC: break
        default: break
        }
    }

}
