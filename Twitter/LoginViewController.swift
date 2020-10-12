//
//  LoginViewController.swift
//  Twitter
//
//  Created by Scott on 10/10/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // if user is logged in, keep logged in
        if UserDefaults.standard.bool(forKey: "userLoggedIn") == true {
            // show login
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        } else {
            // user stays logged out when they log out
            UserDefaults.standard.set(false, forKey: "userLoggedIn")
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func onLoginButton(_ sender: UIButton) {
        // request user authentication
        let myUrl = "https://api.twitter.com/oauth/request_token"
        
        // user login
        TwitterAPICaller.client?.login(url: myUrl, success: {
            
            // store login state
            UserDefaults.standard.bool(forKey: "userLoggedIn")
            
            // show login after success
            self.performSegue(withIdentifier: "loginToHome", sender: self)
        }, failure: { (Error) in
            print("Could not log in.")
        })
    }
    
}
