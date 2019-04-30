//
//  API.swift
//  VDO
//
//  Created by Juan Castillo on 4/26/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import Foundation
import Firebase

class API {
    
    let firestore = Firestore.firestore()
    let videoCollection = Firestore.firestore().collection("videos")
    let albumCollection = Firestore.firestore().collection("albums")
    let userCollection = Firestore.firestore().collection("users")
    let thumbnailsStorageReference = Storage.storage().reference().child("thumbnail_images")
    let userID = Auth.auth().currentUser?.uid as! String
    
    // Uploads a video to the Storage
    func uploadVideoByUser(URL: NSURL){
        
    }
    
    func addVideoToAlbum(){
        
    }
    
    // Returns the user object with the given ID
    func getUser(withId id:String, completion: @escaping (User?) -> Void){
        let docRef = userCollection.document(id)
        docRef.getDocument { (docSnap, error) in
            
            guard error == nil, let doc = docSnap, doc.exists == true else {
                print(error)
                return
            }
            
            let decoder = JSONDecoder()
            
            // make mutable copy of the NSDictionary
            var dict = doc.data()
            for (key, value) in dict! {
                if let value = value as? Date {
                    let formatter = DateFormatter()
                    dict?[key] = formatter.string(from: value)
                }
            }
            
            //Serialize the Dictionary into a JSON Data representation, then decode it using the Decoder().
            if let data = try? JSONSerialization.data(withJSONObject: dict!, options: []) {
                let user = try? decoder.decode(User.self, from: data)
                completion(user)
            }
        }
    }
    
    func fetchVideo(withId id:String, completion: @escaping (Video?) -> Void){
        let docRef = videoCollection.document(id)
        docRef.getDocument { (docSnap, error) in
            
            guard error == nil, let doc = docSnap, doc.exists == true else {
                print(error)
                return
            }
            
            let decoder = JSONDecoder()
            
            // make mutable copy of the NSDictionary
            var dict = doc.data()
            for (key, value) in dict! {
                if let value = value as? Date {
                    let formatter = DateFormatter()
                    dict?[key] = formatter.string(from: value)
                }
            }
            
            //Serialize the Dictionary into a JSON Data representation, then decode it using the Decoder().
            if let data = try? JSONSerialization.data(withJSONObject: dict!, options: []) {
                let video = try? decoder.decode(Video.self, from: data)
                completion(video)
            }
        }
    }
    
//    func getUser(){
//        let userDocument = Firestore.firestore().collection("users").document(userID!)
//        userDocument.getDocument{(document, error) in
//            if let user = document.flatMap({
//                $0.data().flatMap({(data) in
//                    return User(dislpayName: data["displayName"] as! String, email: data["email"] as! String, userID: data["userID"] as! String)
//                })
//            }){
//                print("user: \(user)")
//            } else {
//                print("Document does not exist")
//            }
//        }
//    }
    
    func uploadThumbnailImageForVideo(imageURL: String){
        let storageRef = Storage.storage().reference().child(imageURL)
        
    }
    
    
    // Given a URL of a thumbnail image and a video ID it updates the thumbnail image of the video
    func addThumbnailToVideo(withImage: String, withVideoID: String){
        
    }
    
    
    // Creates an album with the given title for the current user
    func createAlbum(withTitle title: String){
        albumCollection.addDocument(data: [
            "author": userID,
            "title": title,
            "albumAudience": FieldValue.arrayUnion([userID])
            ])
    }
    
    // Adds a reference to the video document into the videos' array of the current user
    func addVideoToUser(videoID: String){
        let userDocument = Firestore.firestore().collection("users").document(userID)
        userDocument.updateData([
            "videos": FieldValue.arrayUnion([videoID])])
    }

    
    // Adds an entry into the database for that video and returns the document ID of that video
    func addVideoToCollection(title: String, fileURL: String ) -> String{
        let video = videoCollection.document()
            video.setData([
            "title": title,
            "albums": FieldValue.arrayUnion([]),
            "audience": FieldValue.arrayUnion([userID]),
            "comments": FieldValue.arrayUnion([]),
            "fileURL": fileURL,
            "notes": ""
            ])
        return video.documentID
    }
    
    // Given an image this function uploads it to firebase storage
    func uploadThumbnailToFireBaseStorageUsingImage(image: UIImage, videoID: String){
        // create a unique name for the thumbnail image
        let imageName = NSUUID.init().uuidString + ".jpeg"
        // create a storage reference for the image
        let ref = Storage.storage().reference().child("thumbnail_images").child(imageName)
        
        if let uploadData = image.jpegData(compressionQuality: 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print("Failed to upload image:", error)
                    return
                } else {
                    ref.downloadURL(completion: {(url, error) in
                        if error != nil {
                            print("failed to get download url", error)
                        } else {
                            let videoDocument = self.videoCollection.document(videoID)
                            videoDocument.updateData([
                                "thumbnail": url!.absoluteString
                                ])
                        }
                    })
                }
            })
        }
    }
}
