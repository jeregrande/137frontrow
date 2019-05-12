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
    
    var user: User?
    let api = API()
    let userID = Auth.auth().currentUser?.uid
    let cellID = "cellid"
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
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("selected cell at index \(indexPath)")
//    }
//
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
//
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as UITableViewCell
        cell.backgroundColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        return cell
    }
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */

}
