//
//  VideoViewController.swift
//  VDO
//
//  Created by Juan Castillo on 5/4/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoViewController: UIViewController {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var video: Video?
    var album: Album? // Only for testing
    let api = API()
    @IBAction func handleFullScreen(_ sender: Any) {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.player
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Play Video", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        videoTitleLabel.text = video?.title
        setVideoThumbnail()
        if let videoURLString = video?.fileURL, let url = NSURL(string: videoURLString) {
            player = AVPlayer(url: url as URL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = videoThumbnail.bounds
            videoThumbnail.layer.addSublayer(playerLayer!)
        }
    }
    
    func setVideoThumbnail(){
        let thumbnailImageURL = video?.thumbnail
        self.api.getThumbnailImage(withImageURL: thumbnailImageURL!, completition: {(image) in
            guard image != nil else {
                print("error")
                return
            }
            self.videoThumbnail.image = image
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "Exit Video View":
                player?.pause()
            default: break
            }
        }
    }

}
