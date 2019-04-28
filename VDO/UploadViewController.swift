//
//  UploadViewController.swift
//  VDO
//
//  Created by Juan Castillo on 4/26/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//
import UIKit
import MobileCoreServices
import Firebase

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagePicker: ImagePicker!
    
    @IBOutlet weak var uploadProgressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

    }
    
    @IBAction func handleUploadTap(_ sender: UIButton) {
//          self.imagePicker.present(from: sender)
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    
    func handleUpload() {
        /// Upload the video
        
        // add it to the database
        
        
    }
    
    private func createDatabaseEntryFromVideo(){
        
    }
    
    private func addVideoToCollection(url: URL, name: String){
        let api = API()
        let vidID = api.addVideoToCollection(title: name, fileURL: url.absoluteString)
        api.addVideoToUser(videoID: vidID)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL{
            handleVideoSelectedForURL(url: videoURL)
        }
        dismiss(animated: true, completion: nil)
    }
    
    public func handleVideoSelectedForURL(url: URL){
        let nsURL = url
        // get the file name
        let fileName =  (url.absoluteString as NSString).lastPathComponent
        let storageRef = Storage.storage().reference().child(fileName)
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
                    self.addVideoToCollection(url: url!, name: fileName)
                    print("Media URL: \(String(describing: url!.absoluteString))")
                }
            })
        } )
        
        // Proggress tracker
        uploadTask.observe(.progress) { snapshot in
            if let fractionCount = snapshot.progress?.fractionCompleted {
                self.uploadProgressBar.isHidden = false
                self.uploadProgressBar.progress = Float(fractionCount)
            }
        }
        
        // Completition Tracker
        uploadTask.observe(.success) { snapshot in
            // Create a segue back to the home view for now
            self.dismiss(animated: true, completion: nil)
            // For the future populate the upload view to be able to edit video title and share it with others
            
        }
        
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
