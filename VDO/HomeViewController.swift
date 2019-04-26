//
//  HomeViewController.swift
//  VDO
//
//  Created by Juan Castillo on 4/10/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import FirebaseUI

class HomeViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBAction func signOut(_ sender: UIButton) {
        let authUI = FUIAuth.defaultAuthUI()
        
        guard authUI != nil else{
            return
        }

        do {
            try authUI?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError{
            print("Error signing out: \(signOutError)")
        } catch {
            print("Unkonwn Error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        userName.text =    FUIAuth.defaultAuthUI()?.auth?.currentUser?.displayName
        // Do any additional setup after loading the view.
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    @IBAction func videoPicker(_ sender: UIButton) {
        self.imagePicker.present(from: sender)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension HomeViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        
    }
}
