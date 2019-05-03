//
//  HomeViewController.swift
//  VDO
//
//  Created by Juan Castillo on 4/10/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import FirebaseUI
import Firebase

class HomeViewController: UIViewController, UIScrollViewDelegate {
    
    var imagePicker: ImagePicker!
    var user: User!
    var videos = [Video]()
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var videosScrollView: UIScrollView!
    
    
    // Sign OUT
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
        // Do any additional setup after loading the view.
        
        
        api.getUser(withId: userID as! String) { (user) in
            guard let u = user else{
                print("error")
                return
            }
            self.user = u
            for video in user!.videos{
                self.api.fetchVideo(withId: video, completion: { (video) in
                    guard let v = video else{
                        print("error")
                        return
                    }
                    self.videos.append(v)
                    self.addVideoToScrollView(video: v)
                })
            }
        }
    }

    
    func addVideoToScrollView(video: Video){
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

