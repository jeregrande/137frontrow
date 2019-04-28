//
//  ImagePicker.swift
//  VDO
//
//  Created by Juan Castillo on 4/26/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import Firebase
import AVKit

public protocol ImagePickerDelegate: class {
    func didSelect(image: UIImage?)
}

open class ImagePicker: NSObject {
    
    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: ImagePickerDelegate?
    
    public init(presentationController: UIViewController, delegate: ImagePickerDelegate) {
        self.pickerController = UIImagePickerController()
        
        super.init()
        
        self.presentationController = presentationController
        self.delegate = delegate
        
        self.pickerController.delegate = self
        self.pickerController.allowsEditing = true
        // Select only MP4 videos for now
        self.pickerController.mediaTypes = [kUTTypeMovie as String]
    }
    
    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }
        
        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }
    
    public func present(from sourceView: UIView) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Save this for now as we can have it record instead of take a photo
//        if let action = self.action(for: .camera, title: "Take photo") {
//            alertController.addAction(action)
//        }
        if let action = self.action(for: .savedPhotosAlbum, title: "Camera roll") {
            alertController.addAction(action)
        }
        if let action = self.action(for: .photoLibrary, title: "Photo library") {
            alertController.addAction(action)
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.presentationController?.present(alertController, animated: true)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)
        
        self.delegate?.didSelect(image: image)
    }
}

extension ImagePicker: UIImagePickerControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL{
            print("Here is the file url:", videoURL)
            
//            handleVideoSelectedForURL(url: videoURL)
            
            
        }
        
        /// Stuff for picking images should be removed at some point
        guard let image = info[.editedImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }
    
    public func handleVideoSelectedForURL(url: NSURL){
        let nsURL = url
        let fileName = "shredding.mov"
        let storageRef = Storage.storage().reference().child(fileName)
        let uploadTask = storageRef.putFile(from: url as URL,metadata: nil, completion: {(metadata, error) in
            if error != nil {
                print("Failed to upload video:", error!)
                return
            }
            
            storageRef.downloadURL(completion: {(url, error) in
                if error != nil {
                    print("Failed to download URL:", error!)
                    return
                } else {
                    
                    if let thumbnailImage = self.thumbnailImageForVideoURL(fileURL: nsURL) {}
                    print("Media URL: \(String(describing: url?.absoluteString))")
                }
            })
        } )
        
        uploadTask.observe(.progress) { snapshot in
            if let completedUnitCount = snapshot.progress?.completedUnitCount {
                
            }
            print("Upload Progress: \(String(describing: snapshot.progress?.completedUnitCount))")
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
}

extension ImagePicker: UINavigationControllerDelegate {
    
}
