//
//  Album.swift
//  VDO
//
//  Created by Juan Castillo on 4/29/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import Foundation

class Album: Codable {
    var albumAudience = [String]()
    var author = ""
    var title = ""
    var albumID = ""
    var videos = [String]()
}
