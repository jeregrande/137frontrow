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
        
                mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        
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
//        let yPosition = self.view.frame.height / 4  * CGFloat(i)
        
        let buttonView = UIButton()
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        buttonView.tag = i
        
        buttonView.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        
        let thumbnailImageURL = video.thumbnail
        self.api.getThumbnailImage(withImageURL: thumbnailImageURL, completition: {(image) in
            guard image != nil else {
                print("error")
                return
            }
            buttonView.setBackgroundImage(image, for: .normal)
            self.mainScrollView.addSubview(buttonView)
            buttonView.setTitle(video.title, for: .normal)
            buttonView.leadingAnchor.constraint(equalTo: self.mainScrollView.leadingAnchor).isActive = true
            buttonView.trailingAnchor.constraint(equalTo: self.mainScrollView.trailingAnchor, constant: 0).isActive = true
            buttonView.widthAnchor.constraint(equalTo: self.mainScrollView.widthAnchor).isActive = true
            buttonView.heightAnchor.constraint(equalTo: buttonView.widthAnchor, multiplier: 9.0/16.0).isActive = true
            buttonView.topAnchor.constraint(equalTo: self.mainScrollView.topAnchor, constant: 260 * CGFloat(i)).isActive = true
            var contentRect = CGRect.zero
            for view in self.mainScrollView.subviews {
                contentRect = contentRect.union(view.frame)
            }
            self.mainScrollView.contentSize = contentRect.size
        })
    }
    
    @objc func didPressButton(sender: UIButton){
        let index = sender.tag
        let video = videos[index]
        print("Button pressed with index: \(sender.tag)")
        performSegue(withIdentifier: "Select Video", sender: video)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Select Video" :
                if let vc = segue.destination as? VideoViewController{
                    vc.video = sender as! Video
                }
            default: break
            }
        }
    }
    
}

