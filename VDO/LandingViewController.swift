//
//  ViewController.swift
//  VDO
//
//  Created by Juan Castillo on 3/6/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import FirebaseUI

class LandingViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func logInTapped(_ sender: UIButton) {
        // Get the default auth UI object
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else{
            return
        }
    
        // set the delegate
        authUI?.delegate = self
        authUI?.providers = [FUIEmailAuth()]
        
        
        // get reference to the auth UI view controller
        let authViewController = authUI!.authViewController()
        
        // show it
        present(authViewController, animated: true, completion: nil)
    }
    
}

extension LandingViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // check if there was an error
        if error != nil {
            // log the error
            return
        }
        
//        authDataResult?.user.id
        performSegue(withIdentifier: "goHome", sender: self)
    }
}
