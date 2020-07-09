//
//  UserModel.swift
//  Auction
//
//  Created by George Digmelashvili on 7/4/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
//

import Firebase

public struct User: Codable {

    var firstname: String
    var lastname: String
    var email: String
    var phone: String
    var isVerified: Bool
    var watchingLots: [DocumentReference]
    var sellingLots: [DocumentReference]
    var wonLots: [DocumentReference]
}


public struct Lots: Codable{
    var id: String
    var name: String
    var description: String
    var startDate: Date
    var endDate: Date
    var currentPrice: Int
    var images: [String]
    var sellerUser: String
    var winnerUser: DocumentReference?
    var soldPrice: String?
    var ended: Bool
    var sold: Bool
    
    init(name: String, desc: String, imgs: [String], seller: String) {
        id = UUID().uuidString
        self.name = name
        description = desc
        startDate = Date() + 20//.random(in: 120...500)
        endDate = startDate + 120
        currentPrice = 0
        images = imgs
        sellerUser = seller
        winnerUser = nil
        soldPrice = nil
        ended = false
        sold = false
    }
}
