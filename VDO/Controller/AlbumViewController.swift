//
//  AlbumViewController.swift
//  VDO
//
//  Created by Juan Castillo on 5/13/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit

class AlbumViewController: UIViewController, UICollectionViewDelegateFlowLayout,  UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    var album = Album(){didSet{
        getVideosForAlbum()
        }}
    var filteredData = [Video]()
    var videos = [Video]()
    let cellID = "cellID"
    let api = API()
    // Workaround for fixing table reloads
    var timer: Timer?
    var alertController = UIAlertController()
    var shareAlertController = UIAlertController()
    
    @IBOutlet weak var albumCollectionView: UICollectionView!
    
    let BUTTON_SHARE = "Share"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActionButton()
        setupAlertController()
        
        // register the Cell here
        albumCollectionView.register(ViewPreviewCell.self, forCellWithReuseIdentifier: cellID)
    }
    
    @IBAction func shareAlert(_ sender: UIBarButtonItem) {
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func setupAlertController(){
        alertController = UIAlertController(title: nil, message: "Share album to user:", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        
        let shareAction = UIAlertAction(title: "Share", style: .default) { (action) in
            print("share album selected")
            self.present(self.shareAlertController, animated: true) {
                // ...
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(shareAction)
    }
    
    func setupActionButton(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: BUTTON_SHARE, style: .plain, target: self, action: #selector(handleShareAction))
    }
    
    @objc func handleShareAction(){
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func setUpNewAlbumAlertController(){
        shareAlertController = UIAlertController(title: "Share Album to user", message: "Enter the name of the user to share to", preferredStyle: UIAlertController.Style.alert)
        
        let shareToUserAction = UIAlertAction(title: "Share", style: .default) { (action) in
            let usernameField = self.shareAlertController.textFields![0] as UITextField
            self.shareAlbumToUser(withUser: usernameField.text!)
        }
        
        shareToUserAction.isEnabled = false
        shareAlertController.addAction(shareToUserAction)
        
        shareAlertController.addTextField { (textField) in
            textField.placeholder = "Recipient's name"
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main) { (notification) in
                shareToUserAction.isEnabled = textField.text != ""
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        shareAlertController.addAction(cancelAction)
    }
    
    func shareAlbumToUser(withUser user: String){
        print("shared album to user: \(user)")
        
        api.addUserToAblum(withAlbum: album.title, withUser: user)
    }
    
    // Get the videos of the album
    func getVideosForAlbum(){
        //        remove all the vids
        print("album object changed")
        videos.removeAll()
        filteredData.removeAll()
        // itterate over all the video ID's for the user and fetch the Video Data
        for videoID in album.videos{
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
    
    @objc func handleReloadTable(){
        DispatchQueue.main.async(execute: {
            print("table data reloaded")
            self.albumCollectionView?.reloadData()
        })
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected at: \(indexPath.item)")
        let video = filteredData[indexPath.item]
        performSegue(withIdentifier: "showVideo", sender: video)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showVideo" :
                if let vc = segue.destination as? VideoViewController{
                    vc.video = sender as? Video
                }
            default: break
            }
        }
    }
}
