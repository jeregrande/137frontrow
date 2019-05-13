//
//  Video.swift
//  VDO
//
//  Created by Juan Castillo on 4/28/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import Foundation

struct Video: Codable {
    var thumbnail = ""
    var videoID = ""
    var ownerID = ""
    var fileURL = ""
    var notes = ""
    var title = ""
    var comments = [String]()
    
}
