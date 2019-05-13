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
    @IBOutlet weak var albumCollectionView: UICollectionView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register the Cell here
        albumCollectionView.register(ViewPreviewCell.self, forCellWithReuseIdentifier: cellID)
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
