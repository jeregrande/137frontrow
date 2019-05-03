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
    
    var imagePicker: ImagePicker!
    var api = API()
    
    @IBOutlet weak var uploadProgressBar: UIProgressView!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
    }
    
    @IBAction func handleUploadTap(_ sender: UIButton) {
        // create the image picker
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        // show the image picker to the user
        present(imagePickerController, animated: true, completion: nil)
    }
    
    // Do this when the user finishes selecting a video from the imagepicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            handleVideoSelectedForURL(url: videoURL)
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func handleVideoSelectedForURL(url: URL){
        let nsURL = url
        if let thumbnail = self.thumbnailImageForVideoURL(fileURL: nsURL as NSURL) {
            // set the Uiimageview as the with the thumbnail image
            self.thumbnailImageView.image = thumbnail
            //            imageName = self.api.uploadThumbnailToFireBaseStorageUsingImage(image: thumbnail)
            // get the file name
            let fileName =  (url.absoluteString as NSString).lastPathComponent
            let storageRef = Storage.storage().reference().child("videos").child(fileName)
            let uploadTask = storageRef.putFile(from: url,metadata: nil, completion: {(metadata, error) in
                
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
                        // create the new video document and get its ID
                        let vidID = self.api.addVideoToDatabase(title: fileName, fileURL: url!.absoluteString)
                        // add the thumbnail image to the video document's values
                        self.api.addVideoToUser(videoID: vidID)
                        //Create the thumbnail Image
                        // upload the image and get the storageURL
                        
                        //                    self.api.addThumbnailToVideo(withImage: self.imageName!, withVideoID: vidID)
                        self.api.uploadThumbnailToFireBaseStorageUsingImage(image: thumbnail, videoID: vidID)
                    }
                })
            } )
            
            // Proggress tracker
            createProgressTrackerForUploadTask(uploadTask: uploadTask)
            
            // Completition Tracker
            createCompletitionTracker(withUploadTask: uploadTask)
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension UploadViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
    }
}
