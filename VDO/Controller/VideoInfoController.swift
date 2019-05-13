//
//  VideoInfoController.swift
//  VDO
//
//  Created by Juan Castillo on 5/12/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import UIKit

class VideoInfoController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: cellID)
        cell.textLabel?.text = tableData[indexPath.item].0
        if let detail = tableData[indexPath.item].1 as? String {
            cell.detailTextLabel?.text = detail
        }
        
        if let detail = tableData[indexPath.item].1 as? NSNumber {
            cell.detailTextLabel?.text = detail.stringValue
        }
        cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        return cell
    }
    
    
    let api = API()
    @IBOutlet weak var metadataTableView: UITableView!
    let cellID = "cellID"
    var tableData = [(String, Any)]()
    
    var video: Video? {didSet{
        getVideoMetadata()
        }}

    override func viewDidLoad() {
        super.viewDidLoad()
        
        metadataTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)

        // Do any additional setup after loading the view.
    }
    
    func getVideoMetadata(){
        let videoref = api.storageRef.reference(forURL: video!.fileURL)
        
        videoref.getMetadata { (metadata, error) in
            if let error = error {
                print("error fecthing metadata of video: \(self.video!.videoID)")
            } else {
//                let decoder = JSONDecoder()
                var dict = metadata?.dictionaryRepresentation()
                print("dict metadata: \(dict)")
                for (index, keyValue) in dict! {
                    self.tableData.append((index, keyValue))
                }
                
                DispatchQueue.main.async(execute:  {
                    self.metadataTableView.reloadData()
                })
                
                
                
//                if let metadata = try? JSONSerialization.data(withJSONObject: dict!, options: []) {
//                    let video = try? decoder.decode(Video.self, from: data)
//                    completion(video)
//                }
            }
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden=true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden=false
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
