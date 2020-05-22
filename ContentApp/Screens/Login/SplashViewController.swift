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

protocol SplashScreenDelegate: class {
    func showAdvancedSettingsScreen()
}

protocol SplashScreenProtocol: class {
    var delegate: SplashScreenDelegate? {get set}
}

class SplashViewController: UIViewController {

    @IBOutlet weak var whiteAlphaView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var blurEfectView: UIVisualEffectView!
    @IBOutlet weak var shadowView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        applyCornerRadius(to: whiteAlphaView)
        applyCornerRadius(to: containerView)
        applyCornerRadius(to: blurEfectView)
        applyShadow(to: shadowView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationBar(hide: true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationBar(hide: false)
    }

    // MARK: - Helpers

    func applyShadow(to baseView: UIView) {
        baseView.layer.shadowColor = UIColor.black.cgColor
        baseView.layer.shadowOpacity = 0.4
        baseView.layer.shadowOffset = .zero
        baseView.layer.shadowRadius = 50.0
        baseView.layer.shadowPath = UIBezierPath(rect: baseView.bounds).cgPath
        baseView.layer.shouldRasterize = true
        baseView.layer.rasterizationScale = UIScreen.main.scale
    }

    func applyCornerRadius(to baseView: UIView) {
        baseView.layer.cornerRadius = 10.0
        baseView.layer.masksToBounds = true
    }

    func navigationBar(hide: Bool) {
        if hide {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case kSegueIDEmbedContentVCInSplashVC:
            if let destinationVC = segue.destination as? UINavigationController {
                if let cvc = destinationVC.viewControllers.first as? ConnectViewController {
                    cvc.delegate = self
                }
            }
        case kSegueIDAdvancedSettingsVCFromConnectVC: break
        default:
            break
        }
    }
}

extension SplashViewController: SplashScreenDelegate {
    func showAdvancedSettingsScreen() {
        self.performSegue(withIdentifier: kSegueIDAdvancedSettingsVCFromConnectVC, sender: nil)
    }
}
