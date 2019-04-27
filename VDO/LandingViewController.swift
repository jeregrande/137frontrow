//
//  ViewController.swift
//  VDO
//
//  Created by Juan Castillo on 3/6/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase
import GoogleSignIn

class LandingViewController: UIViewController, GIDSignInUIDelegate {
    
    var handle: AuthStateDidChangeListenerHandle?

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var continueButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Check for an exisiting log in session
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        handle = Auth.auth().addStateDidChangeListener({(auth, user) in
            if user  != nil {
                self.performSegue(withIdentifier: "goHome", sender: nil)
            }
        })
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
    
    deinit {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
}

extension LandingViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        // check if there was an error
        if error != nil {
            // log the error
            return
        }
        
        guard let userID = authDataResult?.user.uid else {return}
        guard let email = authDataResult?.user.email else {return}
        guard let displayName = authDataResult?.user.displayName else {return}

        // check if the user exist on the users collection
        
        let usersRef = Firestore.firestore().collection("users")
        let docRef = usersRef.document(userID)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                // ther user exist
            } else {
                print("Document does not exist")
                // create the new user document
                usersRef.document(userID).setData([
                    "userID": "\(String(describing: userID))",
                    "videos": FieldValue.arrayUnion([]),
                    "albums": FieldValue.arrayUnion([]),
                    "email": "\(String(describing: email))",
                    "displayName": "\(displayName)"
                    ])
            }
        }
        performSegue(withIdentifier: "goHome", sender: self)
    }
}
