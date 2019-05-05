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
    var user: User! {didSet{getVideosForUser()}}
    var videos = [Video]() {didSet{updateViewFromModel()}}
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
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
        
//        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        // Get the user object
        api.getUser(withId: userID as! String) { (user) in
            guard user != nil else{
                print("error")
                return
            }
            self.user = user
        }
    }
    
    // Get the videos of the user
    func getVideosForUser(){
        print("User's Videos: \(self.user.videos)")
        self.user.videos.forEach({ (videoID) in
            self.api.fetchVideo(withId: videoID, completion: { (video) in
                guard video != nil else {
                    print("error")
                    return
                }
                self.videos.append(video!)
                print("Video Object \(video)")
            })
        })
    }
    
    func updateViewFromModel(){
        let i = videos.endIndex - 1
        let video = videos[i]
        let yPosition = self.view.frame.height / 4  * CGFloat(i)
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: yPosition, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height / 4)
        imageView.contentMode = .scaleAspectFit
        mainScrollView.contentSize.height = (mainScrollView.frame.height / 4) * CGFloat(i + 1)
        
        let thumbnailImageURL = video.thumbnail
        
        //            let storage = Storage.storage()
        //            let storageRef = storage.reference()
        //            let ref = storage.reference(forURL: thumbnailImageURL)
        //            ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
        //                if let error = error {
        //                    print("error \(error)")
        //                } else {
        //                    imageView.image = UIImage(data: data!)
        //                }
        //            }
        
        //            self.api.getThumbnailImage(forVideo: "w3GXULE0jxQLKWMvP6J5", completition: {(image) in
        //                guard image != nil else {
        //                    print("error")
        //                    return
        //                }
        //                imageView.image = image
        //            })
        
        self.api.getThumbnailImage(withImageURL: thumbnailImageURL, completition: {(image) in
            guard image != nil else {
                print("error")
                return
            }
            imageView.image = image
            self.mainScrollView.addSubview(imageView)
        })
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

