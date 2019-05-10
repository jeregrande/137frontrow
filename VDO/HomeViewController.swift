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

class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ViewPreviewCell
        let video = videos[indexPath.item]
        cell.videoTitleLabel.text = video.title
        cell.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected at: \(indexPath.item)")
        let video = videos[indexPath.item]
        performSegue(withIdentifier: "Select Video", sender: video)
    }
    
    var imagePicker: ImagePicker!
    var user: User! {didSet{getVideosForUser()}}
    //    var videos = [Video]() {didSet{addVideoToScrollView()}}
    var videos = [Video]()
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    let cellID = "cellID"
    
    @IBOutlet weak var mainScrollView: UICollectionView!
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
        mainScrollView.register(ViewPreviewCell.self, forCellWithReuseIdentifier: cellID)
        
        api.getUser(withId: userID as! String) { (user) in
            guard user != nil else{
                print("error")
                return
            }
            self.user = user
            //            self.addVideoChangeListener()
        }
    }
    
    func addVideoChangeListener(){
        api.userCollection.document(userID as! String).addSnapshotListener{documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error)")
                return
            }
            guard let data = document.data() else {
                print("Document was empty:")
                return
            }
            // check if the video is already in the array
            if let newVideos = data["videos"] {
                for newVid in newVideos as! Array<String>{
                    if !self.user.videos.contains(newVid){
                        self.user.videos.append(newVid)
                    }
                }
            }
        }
    }
    
    // Get the videos of the user
    func getVideosForUser(){
        //        remove all the vids
        videos.removeAll()
        // itterate over all the video ID's for the user and fetch the Video Data
        for videoID in user.videos{
            api.fetchVideo(withId: videoID) { (video) in
                guard video != nil else {
                    print("error")
                    return
                }
                self.videos.append(video!)
                DispatchQueue.main.async(execute: {
                    self.mainScrollView?.reloadData()
                })
            }
        }
        //        self.user.videos.forEach({ (videoID) in
        //
        //            if !videos.contains(where: { $0.videoID == videoID }){
        //                self.api.fetchVideo(withId: videoID, completion: { (video) in
        //                    guard video != nil else {
        //                        print("error")
        //                        return
        //                    }
        //                    self.videos.append(video!)
        //                })
        //            }
        //            // do nothing, the video is already in the view
        //        })
    }
    
    func addVideoToScrollView(){
        let i = videos.endIndex - 1
        let video = videos[i]
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
            buttonView.contentHorizontalAlignment = .left
            buttonView.contentVerticalAlignment = .bottom
            buttonView.titleLabel?.shadowColor = #colorLiteral(red: 0.240886867, green: 0.2943176925, blue: 0.3582493663, alpha: 1)
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
            buttonView.contentHorizontalAlignment = .left
            buttonView.contentVerticalAlignment = .bottom
            buttonView.titleLabel?.shadowColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
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

