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
    var fileURL = ""
    var title = ""
    var notes = ""
    var albums = [String]()
    var audience = [String]()
    var comments = [String]()
    
}
