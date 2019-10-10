//
//  AuthenticatedViewController.swift
//  DBPSampleApp
//
//  Created by Emanuel Lupu on 09/10/2019.
//  Copyright © 2019 Alfresco. All rights reserved.
//

import UIKit
import MaterialComponents
import AlfrescoAuth

class AuthenticatedViewController: UIViewController {
    @IBOutlet weak var refreshSessionButton: MDCButton!
    
    var authenticatedPresenter = AuthenticatedPresenter()
    
    override func viewDidLoad() {
        authenticatedPresenter.delegate = self
        
        // Refresh section set up
        refreshSessionButton.applyContainedTheme(withScheme: ApplicationScheme.shared.buttonScheme)
        refreshSessionButton.setElevation(ShadowElevation.none, for: .normal)
        refreshSessionButton.setElevation(ShadowElevation.none, for: .highlighted)
        
        refreshSessionButton.setTitle(authenticatedPresenter.refreshSessionText, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.hidesBackButton = true
    }
    
    // MARK: Action handling
    
    @IBAction func refreshSessionTapped(_ sender: Any) {
        authenticatedPresenter.refreshSession()
    }
    @IBAction func logOutTapped(_ sender: Any) {
        authenticatedPresenter.logOut()
        showToastWithMessage(message: LocalizationConstants.AuthenticatedIdentifiers.msgLoggedOut)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: AutenticatedPresenterDelegatez

extension AuthenticatedViewController: AuthenticatedPresenterDelegate {
    func didRefreshSession(message: String) {
        showToastWithMessage(message: message)
    }
    
    func failedToAuthenticate(error: APIError) {
        showToastWithErrorMessage(message: error.localizedDescription)
    }
    
    
}
