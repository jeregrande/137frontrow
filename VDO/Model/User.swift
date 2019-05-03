//
//  User.swift
//  VDO
//
//  Created by Juan Castillo on 4/28/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import Foundation

struct User: Codable{
    var displayName = ""
    var albums = [String]()
    var email = ""
    var userID = ""
    var videos = [String]()
}
