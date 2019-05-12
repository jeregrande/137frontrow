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

class HomeViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIActionSheetDelegate{
    
    var imagePicker: ImagePicker!
    var user: User! {didSet{getVideosForUser()}}
    var videos = [Video]()
    var filteredData = [Video]()
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    let cellID = "cellID"
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mainScrollView: UICollectionView!
    
    var alertController = UIAlertController()
    var profileAlertController = UIAlertController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        observeUser()
        
        setupAlertController()
        setupProfileAlertController()
        
        mainScrollView.translatesAutoresizingMaskIntoConstraints = false
        mainScrollView.register(ViewPreviewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    // Sign OUT DEPRECATED
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
    
    func singOut(){
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
    
    @IBAction func handleProfile(_ sender: UIButton) {
        self.present(profileAlertController, animated: true) {
            // ...
        }
    }
    
    @IBAction func handleNew(_ sender: UIButton) {
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func setupAlertController(){
        alertController = UIAlertController(title: nil, message: "Create a new album or upload a new video", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let newAlbumAction = UIAlertAction(title: "Album", style: .default) { (action) in
            print("new album selected")
        }
        alertController.addAction(newAlbumAction)
        
        let newVideoAction = UIAlertAction(title: "Video", style: .default) { (action) in
            print("new album selected")
        }
        alertController.addAction(newVideoAction)
        //        No need for a destroy action
        //        let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { (action) in
        //            print(action)
        //        }
        //        alertController.addAction(destroyAction)
    }
    
    func setupProfileAlertController(){
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        profileAlertController.addAction(cancelAction)
        let singOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            print(action)
            self.singOut()
        }
        profileAlertController.addAction(singOutAction)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let lowerSearchText = searchText.lowercased()
        filteredData = searchText.isEmpty ? videos : videos.filter { video -> Bool in
            return video.title.lowercased().hasPrefix(lowerSearchText) || video.notes.lowercased().hasPrefix(lowerSearchText)
        }
        DispatchQueue.main.async(execute: {
            self.mainScrollView?.reloadData()
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! ViewPreviewCell
        let video = filteredData[indexPath.item]
        cell.thumbnailView.loadImageUsingCacheWrithURLString(video.thumbnail)
        cell.videoTitleLabel.text = video.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected at: \(indexPath.item)")
        let video = filteredData[indexPath.item]
        performSegue(withIdentifier: "Select Video", sender: video)
    }
    
    // Listen for changes in the user object
    func observeUser(){
        api.addUserDocumentListener(withId: userID!) { (user) in
            guard user != nil else {
                print("user nil")
                return
            }
            self.user = user
        }
    }
    
    // Get the videos of the user
    func getVideosForUser(){
        //        remove all the vids
        print("user object changed")
        videos.removeAll()
        filteredData.removeAll()
        // itterate over all the video ID's for the user and fetch the Video Data
        for videoID in user.videos{
            api.fetchVideo(withId: videoID) { (video) in
                guard video != nil else {
                    print("error could not fetch video with ID: \(videoID)")
                    return
                }
                self.videos.append(video!)
                self.filteredData.append(video!)
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                
            }
        }
    }
    
    // Workaround for fixing table reloads
    var timer: Timer?
    
    @objc func handleReloadTable(){
        DispatchQueue.main.async(execute: {
            print("table data reloaded")
            self.mainScrollView?.reloadData()
        })
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Select Video" :
                if let vc = segue.destination as? VideoViewController{
                    vc.video = sender as? Video
                }
            default: break
            }
        }
    }
    
}

