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

class VideoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var videoNotesTextView: UITextView!
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comment..."
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = false
        return button
    }()
    
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
        videoNotesTextView.text = video?.notes
        setCommentInputComponent()
        
        getComments()
        
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
    
    func setCommentInputComponent(){
        let containerView = UIView()
        containerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        // constraint anchors
        containerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // send button
        sendButton.addTarget(self, action: #selector(handleCommentSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        // text field
        containerView.addSubview(inputTextField)
        inputTextField.addTarget(self, action: #selector(validateCommentText), for: .editingChanged)
        // anchors
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        //        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    @objc func handleCommentSend(){
        print(inputTextField.text)
        api.addComment(withText: inputTextField.text!, toVideo: video!.videoID)
    }
    
    @objc func validateCommentText(){
        print("text changed" )
        if (inputTextField.text != nil) {
            sendButton.isEnabled = true
        } else {
            sendButton.isEnabled = false
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
    
    func getComments(){
        for comment in video!.comments{
            api.fetchComment(withId: comment) { (comment) in
                print("Comment: \(comment?.body)")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleCommentSend()
        return true
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
