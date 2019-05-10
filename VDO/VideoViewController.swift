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

class VideoViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var videoTitleLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var videoNotesTextView: UITextView!
    
    let cellID = "CellId"
    
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
    
    lazy var commentView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var video: Video?
    var comments = [Comment]()
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
        self.commentView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        videoTitleLabel.text = video?.title
        videoNotesTextView.text = video?.notes
        setCommentInputComponent()
        
        observeComments()
        
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
        switch sender.tag {
        case 0:
            playVideo()
            sender.tag = 1
            sender.setImage(UIImage(named: "pause_button"), for: .normal)
        case 1:
            pauseVideo()
            sender.tag = 0
            sender.setImage(UIImage(named: "play_button"), for: .normal)
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
        
        view.addSubview(commentView)
        commentView.topAnchor.constraint(equalTo: videoNotesTextView.bottomAnchor, constant: 10).isActive = true
        commentView.bottomAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        commentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        commentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }

    
    @objc func handleCommentSend(){
        api.addComment(withText: inputTextField.text!, toVideo: video!.videoID)
        inputTextField.text = nil
    }
    
    @objc func validateCommentText(){
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
                self.comments.append(comment!)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleCommentSend()
        return true
    }
    
    func observeComments(){
        let listener = api.videoCollection.document(video!.videoID).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document \(error)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty")
                return
            }
            if let newComments = data["comments"] {
                for newComment in newComments as! Array<String> {
                    if !(self.video?.comments.contains(newComment))!{
                        self.api.fetchComment(withId: newComment) { (comment) in
                            print("Comment: \(comment?.body)")
                            self.video?.comments.append(newComment)
                            
                            DispatchQueue.main.async(execute: {
                                self.commentView.reloadData()
                            })
                        }
                    }
                }
            }
        }

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return video?.comments.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (tableView.dequeueReusableCell(withIdentifier: cellID) as UITableViewCell?)!
        api.fetchComment(withId: (video?.comments[indexPath.row])!) { (comment) in
            print("Comment: \(comment?.body)")
            self.comments.append(comment!)
            cell.textLabel?.text  = comment?.body
            cell.detailTextLabel?.text = "By user: at time )"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
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
