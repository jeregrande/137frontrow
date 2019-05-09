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
    @IBOutlet weak var progressBar: UIProgressView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var video: Video?
    let api = API()
    @IBAction func handleFullScreen(_ sender: Any) {
        player?.pause()
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(avPlayerClosed), name: Notification.Name("avPlayerDidDismiss"), object: nil)
        present(playerViewController, animated: true) {() in
            DispatchQueue.main.async {
                self.player?.play()
            }
        }
    }
    
    @objc func avPlayerClosed(_ notifiaction: Notification){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {() in
            self.player?.play()
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
            let asset = AVAsset(url: url as URL)
            let playerItem = AVPlayerItem(asset: asset)
            
            player = AVPlayer(playerItem: playerItem)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = videoThumbnail.bounds
            playerLayer?.videoGravity = .resizeAspect
            videoThumbnail.layer.addSublayer(playerLayer!)
            player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 2), queue: DispatchQueue.main) {[weak self] (progressTime) in
                if let duration = self!.player?.currentItem?.duration {
                    
                    let durationSeconds = CMTimeGetSeconds(duration)
                    let seconds = CMTimeGetSeconds(progressTime)
                    let progress = Float(seconds/durationSeconds)
                    
                    DispatchQueue.main.async {
                        self?.progressBar.progress = progress
                        if progress >= 1.0 {
                            self?.progressBar.progress = 0.0
                        }
                    }
                }
            }
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
            self.progressBar.isHidden = false
        })
    }
    @IBAction func handlePlayPause(_ sender: UIButton) {
        switch sender.currentTitle {
        case "Play":
            playVideo()
            sender.setTitle("Pause", for: .normal)
        case "Pause":
            pauseVideo()
            sender.setTitle("Play", for: .normal)
        default:
            break
        }
    }
    
    public func playVideo(){
        print("playVid")
        player?.play()
    }
    
    public func pauseVideo(){
        print("Pause vid")
        player?.pause()
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
    deinit {
        NotificationCenter.default.removeObserver(self)
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
}

extension AVPlayerViewController {
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.player?.pause()
        NotificationCenter.default.post(name: Notification.Name("avPlayerDidDismiss"), object: nil, userInfo: nil)
    }
}
