//
//  User.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Foundation

struct UserResponse: Codable {
    let response: [User]
}

struct User: Codable {
    let name: String   // 姓名
    let kokoid: String // kokoID
}

/*
 {
   "response": [
     {
       "name": "蔡國泰",
       "kokoid": "Mike"
     }
   ]
 }
 */
