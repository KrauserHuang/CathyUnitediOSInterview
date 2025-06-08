//
//  Friend.swift
//  CathyUnitediOSInterview
//
//  Created by Tai Chin Huang on 2025/6/8.
//

import Foundation

struct FriendResponse: Codable {
    let friends: [Friend]
    
    enum CodingKeys: String, CodingKey {
        case friends = "response"
    }
}

struct Friend: Codable {
    let name: String?       // 姓名
    let status: Int?        // 好友狀態，0:邀請送出，1:已完成，2:邀請中
    let isTop: String?      // 是否出現星星
    let fid: String?        // 好友ID
    let updateDate: String? // 資料更新時間
}

enum FriendStatus: Int {
    case invitingSent = 0
    case completed = 1
    case inviting = 2
    
    init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .invitingSent
        case 1: self = .completed
        case 2: self = .inviting
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .invitingSent: return "邀請送出"
        case .completed: return "已完成"
        case .inviting: return "邀請中"
        }
    }
}

/*
 {
   "response": [
     {
       "name": "黃靖僑",
       "status": 0,
       "isTop": "0",
       "fid": "001",
       "updateDate": "20190801"
     },
     {
       "name": "翁勳儀",
       "status": 2,
       "isTop": "1",
       "fid": "002",
       "updateDate": "20190802"
     },
     {
       "name": "洪佳妤",
       "status": 1,
       "isTop": "0",
       "fid": "003",
       "updateDate": "20190804"
     },
     {
       "name": "梁立璇",
       "status": 1,
       "isTop": "0",
       "fid": "004",
       "updateDate": "20190801"
     },
     {
       "name": "梁立璇",
       "status": 1,
       "isTop": "0",
       "fid": "005",
       "updateDate": "20190804"
     }
   ]
 }
 */
