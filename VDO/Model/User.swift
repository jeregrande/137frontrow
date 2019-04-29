//
//  User.swift
//  VDO
//
//  Created by Juan Castillo on 4/28/19.
//  Copyright © 2019 137frontrow. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct User{
    
    var dislpayName: String
//    var albums: [Album]
    var email: String
    var userID: String
    var videos: [Video]
    
    var dictitonary: [String: Any] {
        return [
            "displayName": dislpayName,
            "email": email,
            "userID": userID
        ]
    }
}
