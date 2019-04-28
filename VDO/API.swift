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
    
    let videoCollection = Firestore.firestore().collection("videos")
    let albumCollection = Firestore.firestore().collection("albums")
    let userID = Auth.auth().currentUser?.uid
    
    // Uploads a video to the Storage
    func uploadVideoByUser(URL: NSURL){
        
    }
    
    func addVideoToAlbum(){
        
    }
    
    // Returns an array of the videos uploaded by the user
    func getOwnVideos(){
        let userDocument = Firestore.firestore().collection("users").document(userID!)
        userDocument.getDocument{(document, error) in
            if let document = document, document.exists {
                let videos = document.get("videos")
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(videos)")
            }
            else {
                print("Document does not exist")
            }
        }
    }
    
    func uploadThumbnailImageForVideo(imageURL: String){
        let storageRef = Storage.storage().reference().child(imageURL)
        storageRef.putFile(from: <#T##URL#>)
    }
    
    
    // Creates an album with the given title for the current user
    func createAlbum(withTitle: String){
        let userDocument = Firestore.firestore().collection("users").document(userID!)
        albumCollection.addDocument(data: [
            "author": userDocument,
            "albumAudience": FieldValue.arrayUnion([userDocument])
            ])
    }
    
    // Adds a reference to the video document into the videos' array of the current user
    func addVideoToUser(videoID: String){
        let userDocument = Firestore.firestore().collection("users").document(userID!)
        let videoReference = videoCollection.document(videoID)
        userDocument.updateData([
            "videos": FieldValue.arrayUnion([videoReference])])
    }

    
    // Adds an entry into the database for that video and returns the document ID of that video
    func addVideoToCollection(title: String, fileURL: String ) -> String{
        let video = videoCollection.document()
            video.setData([
            "title": title,
            "albums": FieldValue.arrayUnion([]),
            "audience": FieldValue.arrayUnion([Firestore.firestore().collection("users").document(userID!)]),
            "comments": FieldValue.arrayUnion([]),
            "fileURL": fileURL,
            "format":"mov",
            "length": 60,
            "notes": ""
            ])
        return video.documentID
    }
}
