//
//  SharedAlbumsViewController.swift
//  VDO
//
//  Created by Juan Castillo on 5/12/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import Firebase

class SharedAlbumsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var user: User? {didSet{
        getAlbumsSharedWithUser()
        }}
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    let cellID = "cellid"
    var albums = [Album]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        observeUser()
    }
    
    // Listen for changes in the user object
    func observeUser(){
        api.addUserDocumentListener(withId: userID!) { (user) in
            guard user != nil else {
                print("user nil")
                return
            }
            self.user = user
            print("user: \(user)")
        }
    }
    
    func getAlbumsSharedWithUser(){
        api.getAlbumsShared(withUser: userID!) { (albums) in
            guard albums != nil else {
                print("No albums or could not fetch")
                return
            }
            print("Albums shared with the user \(albums)")
            
            for albumID in albums {
                self.api.fetchAlbum(withId: albumID, completion: { (album) in
                    self.albums.append(album!)
                    DispatchQueue.main.async(execute: {
                        print("table data reloaded")
                        self.tableView.reloadData()
                    })
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    //
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellID)
        cell.textLabel?.text = albums[indexPath.item].title
        if let count = albums[indexPath.item].videos.count as? NSNumber {
            var postfix = ""
            switch count {
            case 1:
                postfix = " video"
            default:
                postfix = " videos"
            }
            cell.detailTextLabel?.text = count.stringValue + postfix
        }
        cell.selectionStyle = .blue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected item at \(indexPath.row)")
        performSegue(withIdentifier: "showAlbum", sender: albums[indexPath.item])
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "showAlbum":
                if let vc = segue.destination as? AlbumViewController {
                    vc.album = (sender as? Album)!
                }
            default: break
            }
        }
    }
}
