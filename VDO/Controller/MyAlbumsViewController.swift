//
//  MyAlbumsViewController.swift
//  VDO
//
//  Created by Juan Castillo on 5/13/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit
import Firebase

class MyAlbumsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {
    
    var user: User? {didSet{
        getUserAlbums()
    }}
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    let cellID = "cellid"
    var albums = [Album]()
    @IBOutlet weak var tableView: UITableView!
    var alertController = UIAlertController()
    var newAlbumAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupAlertController()
        setUpNewAlbumAlertController()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        // Do any additional setup after loading the view.
        observeUser()
    }
    
    @IBAction func handleNew(_ sender: UIBarButtonItem) {
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func setupAlertController(){
        alertController = UIAlertController(title: nil, message: "Create a new album or upload a new video", preferredStyle: UIAlertController.Style.actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let newAlbumAction = UIAlertAction(title: "Album", style: .default) { (action) in
            print("new album selected")
            self.present(self.newAlbumAlertController, animated: true) {
                // ...
            }
        }
        alertController.addAction(newAlbumAction)
        
        let newVideoAction = UIAlertAction(title: "Video", style: .default) { (action) in
            print("new video selected")
            self.performSegue(withIdentifier: "handleNewVideo", sender: nil)
        }
        alertController.addAction(newVideoAction)
        //        No need for a destroy action
        //        let destroyAction = UIAlertAction(title: "Destroy", style: .destructive) { (action) in
        //            print(action)
        //        }
        //        alertController.addAction(destroyAction)
    }
    
    func setUpNewAlbumAlertController(){
        newAlbumAlertController = UIAlertController(title: "Create a new album", message: "Enter the name of the new album", preferredStyle: UIAlertController.Style.alert)
        
        let createAlbumAction = UIAlertAction(title: "Create", style: .default) { (action) in
            //...
        }
        newAlbumAlertController.addAction(createAlbumAction)
        
        newAlbumAlertController.addTextField { (textField) in
            textField.placeholder = "Album name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            // ...
        }
        newAlbumAlertController.addAction(cancelAction)
    }
    
    func getUserAlbums(){
        for albumID in user!.albums {
            api.fetchAlbum(withId: albumID) { (album) in
                guard album != nil else {
                    print("error getting album data")
                    return
                }
                
                self.albums.append(album!)
                DispatchQueue.main.async(execute: {
                    print("table data reloaded")
                    self.tableView.reloadData()
                })
                print("album data \(String(describing: album?.title))")
            }
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
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
        performSegue(withIdentifier: "show_album", sender: albums[indexPath.item])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show_album":
                if let vc = segue.destination as? AlbumViewController {
                    vc.album = (sender as? Album)!
                }
            default: break
            }
        }
    }
}
