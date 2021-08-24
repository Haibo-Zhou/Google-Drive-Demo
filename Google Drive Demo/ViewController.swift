//
//  ViewController.swift
//  Google Drive Demo
//
//  Created by HaiboZhou on 2021/8/23.
//

import UIKit

import GTMSessionFetcher
import GoogleSignIn
import GoogleAPIClientForREST
import UIKit


class ViewController: UIViewController {
    var stateManager: StateManager!
    
    var signInButton: GIDSignInButton = {
        let btn = GIDSignInButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.style = .wide
        btn.colorScheme = .dark
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    var signOutButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Sign out", for: .normal)
        //        btn.layer.cornerRadius = 12
        btn.backgroundColor = .myBlue
        btn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        btn.sizeToFit()
        btn.isHidden = true
        btn.addTarget(self, action: #selector(signOutButtonTapped), for: .touchUpInside)
        return btn
    }()
    
    var greetingLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please sign in... 🙂"
        label.textAlignment = .center
        label.sizeToFit()
        label.backgroundColor = .tertiarySystemFill
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Main View"
        
        setViews()
        setBackgroundImage(imageName: "GoogleSignInBgImage")
        restoreSignIn()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signOutButton.layer.cornerRadius = signOutButton.frame.height / 2
    }
    
    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if error != nil || user == nil {
                print("ERRRR: \(String(describing: error)), \(String(describing: error?.localizedDescription))")
                self?.updateScreen()
            } else {
                // Post notification after user successfully sign in
                guard let user = user else { return }
                print("restore signIn state")
                self?.createGoogleDriveService(user: user)
            }
        }
    }
    
    
    private func updateScreen() {
        
        if let user = GIDSignIn.sharedInstance.currentUser {
            // User signed in
            // Show greeting message
            greetingLabel.text = "Hello \(user.profile?.givenName ?? "") 😃"
            
            // Hide sign in button
            signInButton.isHidden = true
            
            // Show sign out button
            signOutButton.isHidden = false
            
        } else {
            // User signed out
            
            // Show sign in message
            greetingLabel.text = "Please sign in."
            
            // Show sign in button
            signInButton.isHidden = false
            
            // Hide sign out button
            signOutButton.isHidden = true
        }
    }
    
    func setViews() {
        view.addSubview(greetingLabel)
        view.addSubview(signInButton)
        view.addSubview(signOutButton)
        
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            signInButton.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            signInButton.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            
            signOutButton.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            signOutButton.centerYAnchor.constraint(equalTo: g.centerYAnchor),
            signOutButton.widthAnchor.constraint(equalTo: signInButton.widthAnchor),
            
            greetingLabel.centerXAnchor.constraint(equalTo: g.centerXAnchor),
            greetingLabel.bottomAnchor.constraint(equalTo: signInButton.topAnchor, constant: -30),
            greetingLabel.widthAnchor.constraint(equalTo: g.widthAnchor, multiplier: 0.42),
        ])
    }
    
    @objc func signInButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(with: stateManager.signInConfig, presenting: self) { [weak self] user, error in
            
            guard let self = self else { return }
            
            if let error = error {
                print("SignIn failed, \(error), \(error.localizedDescription)")
            } else {
                print("Authenticate successfully")
                let driveScope = "https://www.googleapis.com/auth/drive.readonly"
                guard let user = user else { return }
                
                let grantedScopes = user.grantedScopes
                print("scopes: \(String(describing: grantedScopes))")
                
                if grantedScopes == nil || !grantedScopes!.contains(driveScope) {
                    // Request additional Drive scope if it doesn't exist in scope.
                    GIDSignIn.sharedInstance.addScopes([driveScope], presenting: self) { [weak self] user, error in
                        if let error = error {
                            print("add scope failed, \(error), \(error.localizedDescription)")
                        }
                        
                        guard let user = user else { return }
                        
                        DispatchQueue.main.async {
                            print("userDidSignInGoogle")
                            self?.updateScreen()
                        }
                        
                        // Check if the user granted access to the scopes you requested.
                        if let scopes = user.grantedScopes,
                           scopes.contains(driveScope) {
                            print("Scope added")
                            print(" NEW scopes: \(String(describing: scopes))")
                            self?.createGoogleDriveService(user: user)
                        }
                    }
                }
            }
        }
    }
    
    @objc func signOutButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.disconnect(callback: nil)
        print("Did disconnect to user")
        // Update screen after user successfully signed out
        updateScreen()
    }
    
    
    func createGoogleDriveService(user: GIDGoogleUser) {
        // set service type to GoogleDrive
        let service = GTLRDriveService()
        service.authorizer = user.authentication.fetcherAuthorizer()
        
        // dependency inject
        stateManager.googleAPIs = GoogleDriveAPI(service: service)
        
        user.authentication.do { [weak self] authentication, error in
            guard error == nil else { return }
            guard let authentication = authentication else { return }
            
            // Get the access token to attach it to a REST or gRPC request.
            // let accessToken = authentication.accessToken
            
            // Or, get an object that conforms to GTMFetcherAuthorizationProtocol for
            // use with GTMAppAuth and the Google APIs client library.
            let service = GTLRDriveService()
            service.authorizer = authentication.fetcherAuthorizer()
            
            // dependency inject
            self?.stateManager.googleAPIs = GoogleDriveAPI(service: service)
            
            let vc = GoogleDriveViewController()
            vc.stateManager = self?.stateManager
            self?.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

