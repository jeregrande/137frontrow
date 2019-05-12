//
//  UploadViewController.swift
//  VDO
//
//  Created by Juan Castillo on 4/26/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//
import UIKit
import AVKit
import MobileCoreServices
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let SELECT_VIDEO = "Select Video"
    let UPLOAD_VIDEO = "Upload"
    
    var imagePicker: ImagePicker!
    var api = API()
    var videoURL: URL?
    var thumbnailURL: URL?
    
    @IBOutlet weak var uploadProgressBar: UIProgressView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var helperTextLabel: UILabel!
    
    var albumPickerActionSheet = UIView()
    var albumPickerActionSheetBottomAnchor: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // make sure the button has the appropriate title when the VC is created.
        actionButton.setTitle(SELECT_VIDEO, for: .normal)
        view.addSubview(albumPickerActionSheet)
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func addToAlbum(_ sender: UIButton) {
        
    }
    
    
    func handleSelectVideoTap() {
        // create the image picker
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        // show the image picker to the user
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleUploadVideoTap(){
        // Check that the title field is not empty
        if let title = titleField.text {
            //         get the file name
            let fileName =  (videoURL!.absoluteString as NSString).lastPathComponent
            let storageRef = Storage.storage().reference().child("videos").child(fileName)
            let uploadTask = storageRef.putFile(from: videoURL!,metadata: nil, completion: {(metadata, error) in
                
                if error != nil {
                    print("Failed to upload video:", error!)
                    return
                }
                
                // Get the uploaded url
                storageRef.downloadURL(completion: {(url, error) in
                    if error != nil {
                        print("Failed to download URL:", error!)
                        return
                    } else {
                        // Add video to the videos collection
                        
                        let notes = self.notesTextView.text
                        // create the new video document and get its ID
                        let vidID = self.api.addVideoToDatabase(title: title, fileURL: url!.absoluteString, notes: notes!)
                        // add the thumbnail image to the video document's values
                        
                        
                        self.api.addVideoToUser(videoID: vidID)
                        //Create the thumbnail Image
                        // upload the image and get the storageURL
                        self.api.uploadThumbnailToFireBaseStorageUsingImage(image: self.thumbnailImageView!.image!, videoID: vidID)
                    }
                })
            } )
            
            // Proggress tracker
            createProgressTrackerForUploadTask(uploadTask: uploadTask)
            
            // Completition Tracker
            createCompletitionTracker(withUploadTask: uploadTask)
        }
    }
    
    // Handle the action depending on the button's text
    @IBAction func handleActionButtonPressed(_ sender: UIButton) {
        switch sender.currentTitle {
        case SELECT_VIDEO:
            handleSelectVideoTap()
        case UPLOAD_VIDEO:
            handleUploadVideoTap()
        default:
            break
        }
    }
    
    func showEditFields(){
        helperTextLabel.isHidden = true
        titleField.isHidden = false
        titleLabel.isHidden = false
        notesLabel.isHidden = false
        notesTextView.isHidden = false
    }
    
    
    // Do this when the user finishes selecting a video from the imagepicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            handleVideoSelectedForURL(url: videoURL)
            showEditFields()
            self.videoURL = videoURL
        }
        dismiss(animated: true, completion: nil)
    }
    
    // Prepares the video for upload process
    public func handleVideoSelectedForURL(url: URL){
        let nsURL = url
        actionButton.setTitle(UPLOAD_VIDEO, for: .normal)
        
        if let thumbnail = self.thumbnailImageForVideoURL(fileURL: nsURL as NSURL) {
            // set the Uiimageview as the with the thumbnail image
            self.thumbnailImageView.image = thumbnail
        }
    }
    
    private func createProgressTrackerForUploadTask(uploadTask: StorageUploadTask){
        uploadTask.observe(.progress) { snapshot in
            if let fractionCount = snapshot.progress?.fractionCompleted {
                self.uploadProgressBar.isHidden = false
                self.uploadProgressBar.progress = Float(fractionCount)
            }
        }
    }
    
    private func createCompletitionTracker(withUploadTask: StorageUploadTask){
        withUploadTask.observe(.success) { snapshot in
            // Create a segue back to the home view for now
            self.dismiss(animated: true, completion: nil)
            // For the future populate the upload view to be able to edit video title and share it with others
        }
    }
    
    // Creates a thumbnail image from the first frame of the video
    public func thumbnailImageForVideoURL(fileURL: NSURL) -> UIImage? {
        let asset = AVAsset(url: fileURL as URL)
        let imageGenereator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenereator.copyCGImage(at: CMTimeMake(value: 1,timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        return nil
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension UploadViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
    }
}
