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
    //var user: User! {didSet{getVideosForUser(); getAlbumsForUser()}}
    //var user: User! {didSet{getVideosForUser()}}
    var user: User! {didSet{getAlbumsForUser()}}
    var albums = [Album]() {didSet{updateViewFromModel()}}
    //var videos = [Video]() {didSet{updateViewFromModel()}}
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var navBarChooser: UISegmentedControl! //The top bar selector in HomeViewController
    
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
            print("Unknown Error")
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
    
//    // Get the videos of the user
//    func getVideosForUser(){
//        print("User's Videos: \(self.user.videos)")
//        self.user.videos.forEach({ (videoID) in
//            self.api.fetchVideo(withId: videoID, completion: { (video) in
//                guard video != nil else {
//                    print("error")
//                    return
//                }
//                self.videos.append(video!)
//                print("Video Object \(video)")
//            })
//        })
//    }
//
//    //Video display format
//    func updateViewFromModel(){
//        let i = videos.endIndex - 1
//        let video = videos[i]
//        let yPosition = self.view.frame.height / 4  * CGFloat(i)
//
//        let buttonView = UIButton()
//        buttonView.tag = i
//        buttonView.frame = CGRect(x: 0, y: yPosition, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height / 4)
//
//
//        buttonView.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
//        mainScrollView.contentSize.height = (mainScrollView.frame.height / 4) * CGFloat(i + 1)
//
//        let thumbnailImageURL = video.thumbnail
//        let videoTitle = video.title
//        self.api.getThumbnailImage(withImageURL: thumbnailImageURL, completition: {(image) in
//            guard image != nil else {
//                print("error")
//                return
//            }
//            buttonView.setBackgroundImage(image, for: .normal)
//            self.mainScrollView.addSubview(buttonView)
//        })
//
//        buttonView.setTitle(videoTitle, for: .normal) //Set button to display title
//        self.mainScrollView.addSubview(buttonView)
//    }
//
//    //Video Button listener
//    @objc func didPressButton(sender: UIButton){
//        let index = sender.tag
//        let video = videos[index]
//        print("Button pressed with index: \(sender.tag)")
//        performSegue(withIdentifier: "Select Video", sender: video)
//    }

    //Get user's albums
    func getAlbumsForUser() {
        print("User's Albums: \(self.user.albums)")
        self.user.albums.forEach({ (albumID) in
            self.api.fetchAlbum(withId: albumID, completion: { (album) in
                guard album != nil else {
                    print("error")
                    return
                }
                self.albums.append(album!)
                print("Album Object \(album)")
            })
        })
    }

    //Album display format
    func updateViewFromModel(){
        let i = albums.endIndex - 1
        let album = albums[i]
        let yPosition = self.view.frame.height / 8  * CGFloat(i)

        let buttonView = UIButton()
        buttonView.tag = i
        buttonView.frame = CGRect(x: 0, y: yPosition, width: self.mainScrollView.frame.width, height: self.mainScrollView.frame.height / 8)

        buttonView.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        mainScrollView.contentSize.height = (mainScrollView.frame.height / 8) * CGFloat(i + 1)

        let albumTitle = album.title
        buttonView.backgroundColor = UIColor.purple
        buttonView.setTitle(albumTitle, for: .normal)        //buttonView.setTitleColor(.silver, for: .normal)
        self.mainScrollView.addSubview(buttonView)
    }

    //Album Button listener
    @objc func didPressButton(sender: UIButton){
        let index = sender.tag
        let album = albums[index]
        print("Button pressed with index: \(sender.tag)")
        performSegue(withIdentifier: "Select Album", sender: album)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
//    //Video segue to VideoViewController
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let identifier = segue.identifier {
//            switch identifier {
//            case "Select Video" :
//                if let vc = segue.destination as? VideoViewController{
//                    vc.video = sender as! Video
//                }
//            default: break
//            }
//        }
//    }


    //Album segue to HomeViewController?------------------------------------------------------------------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Select Album" :
                if let vc = segue.destination as? AlbumViewController{  //Segue to new AlbumViewController
                    vc.album = sender as! Album
                }
            default: break
            }
        }
    }
}

