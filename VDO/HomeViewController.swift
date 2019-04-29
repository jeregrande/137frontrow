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

class HomeViewController: UIViewController {
    
    var imagePicker: ImagePicker!
    var user: User!
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
        
        let api = API()
////        api.getUser()
//        let userDocument = Firestore.firestore().collection("users").document(userID!)
//        userDocument.getDocument{(document, error) in
//            if let document = document, document.exists {
//                let videos = document.get("videos")
//                print(videos)
//                for video in (videos as? NSArray)! {
//                    let ref = video as? DocumentReference
//                    ref?.getDocument{ (document, error) in
//                        if let vid = document.flatMap({
//                            $0.data().flatMap({(data) in
//                                return Video(thumbnail: Storage.storage().reference().child("thumbnail_images").child(data["thumbnail"] as! String).write(toFile: URL("thumbnails/")), fileURL: data["fileURL"], title: data["title"])
//                            })
//                        })
//                    }
//                    
//                }
//        }
//        }
        
    }
    
//    func updateViewFromModel(){
//        for index in videos.indices {
//            let imageView = videos[index]
//            let video = user.videos[index]
//        }
//    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

