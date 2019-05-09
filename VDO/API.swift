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
    let storageRef = Storage.storage()
    let thumbnailsStorageReference = Storage.storage().reference().child("thumbnail_images")
    let userID = Auth.auth().currentUser?.uid as! String
    
    
    // Returns the user object with the given ID
    func getUser(withId id:String, completion: @escaping (User?) -> Void){
        let docRef = userCollection.document(id)
        docRef.getDocument { (docSnap, error) in
            
            guard error == nil, let doc = docSnap, doc.exists == true else {
                print("Error Document not Found: \(error.debugDescription)")
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
                print("Error Document not Found: \(error.debugDescription)")
                return
            }
            
            let decoder = JSONDecoder()
            
            // make mutable copy of the NSDictionary
            var dict = doc.data()
            print(doc.data())
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
    
    // Gets the given album object given the album's ID
    func fetchAlbum(withId id:String, completion: @escaping (Album?) -> Void){
        let docRef = videoCollection.document(id)
        docRef.getDocument { (docSnap, error) in
            
            guard error == nil, let doc = docSnap, doc.exists == true else {
                print("Error Document not Found: \(error.debugDescription)")
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
                let album = try? decoder.decode(Album.self, from: data)
                completion(album)
            }
        }
    }
    
    // Returns an array of Album id's where the userID is in the album audience
    func getAlbumsShared(withUser user: String, completion: @escaping ([String]) -> Void){
        var albums = [String]()
        let querry = albumCollection.whereField("albumAudience", arrayContains: user)
        querry.getDocuments { (qs, error) in
            qs?.documents.forEach({ (document) in
                albums.append(document.documentID)
            })
            completion(albums)
        }
    }
    
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
            "videos": FieldValue.arrayUnion([]),
            "albumAudience": FieldValue.arrayUnion([userID])
            ])
    }
    
    
    func addUserToAblum(withAlbum album: String, withUser user: String){
        albumCollection.document(album).updateData([
            "albumAudience": user
            ])
    }
    
    func removeUserFromAlbum(withAlbum album: String, withUser user: String){
        albumCollection.document(album).updateData([
            "albumAudience": FieldValue.arrayRemove([user])
            ])
    }
    
    func deleteAlbum(withAlbum album: String){
        albumCollection.document(album).delete(){ err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
    
    func addVideoToAlbum(withVideo video: String, withAlbum album: String){
        albumCollection.document(album).updateData([
            "videos": FieldValue.arrayUnion([album])
            ])
    }
    
    func removeVideoWithAlbum(withVideo video:String, withAlbum album: String){
        albumCollection.document(album).updateData([
            "videos": FieldValue.arrayRemove([video])
            ])
    }
    
    
    // Adds a reference to the video document into the videos' array of the current user
    func addVideoToUser(videoID: String){
        let userDocument = Firestore.firestore().collection("users").document(userID)
        userDocument.updateData([
            "videos": FieldValue.arrayUnion([videoID])])
    }
    
    // Adds all thevideos in one album to the other album
    func addAlbumToAlbum(from album: String,to : String){
        albumCollection.document(album).getDocument { (document, error) in
            if let document = document, document.exists {
                if let audience = document.get("videos") {
                    self.albumCollection.document(to).updateData([
                        "videos": FieldValue.arrayUnion(audience as! [Any])
                        ])
                }
            }
        }
    }
    
    
    // Adds an entry into the database for that video and returns the document ID of that video
    func addVideoToDatabase(title: String, fileURL: String, notes: String ) -> String{
        let video = videoCollection.document()
        video.setData([
            "comments": FieldValue.arrayUnion([]),
            "fileURL": fileURL,
            "notes": notes,
            "title": title
            ])
        return video.documentID
    }
    
    // Given an image this function uploads it to firebase storage
    func uploadThumbnailToFireBaseStorageUsingImage(image: UIImage, videoID: String){
        // create a unique name for the thumbnail image
        let imageName = videoID + ".jpeg"
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
    
    func getThumbnailImage(forVideo videoID: String, completition: @escaping (UIImage) -> Void) {
        let ref = thumbnailsStorageReference.child(videoID + ".jpeg")
        ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("error \(error)")
            } else {
                completition(UIImage(data: data!)!)
            }
        }
    }
    
    func getThumbnailImage(withImageURL imageURL: String, completition: @escaping (UIImage) -> Void){
        let ref = storageRef.reference(forURL: imageURL)
        ref.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("error \(error)")
            } else {
                completition(UIImage(data: data!)!)
            }
        }
    }
    
    // deletes the given video from the user's list of videos 
    func delete(video: String){
        let userRef = userCollection.document(userID).updateData([
            "videos": FieldValue.arrayRemove([video])
            ])
        // TODO go through all the comments and delte this video
        let querry = albumCollection.whereField("videos", arrayContains: video)
        querry.getDocuments { (qs, error) in
            qs?.documents.forEach({ (document) in
                self.removeVideoWithAlbum(withVideo: video, withAlbum: document.documentID)
            })
        }
        videoCollection.document(video).delete()
    }
}
