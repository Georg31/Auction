//
//  UserModel.swift
//  Auction
//
//  Created by George Digmelashvili on 7/4/20.
//  Copyright © 2020 George Digmelashvili. All rights reserved.
// 4/1wHqcukFBpwaI5AIBsQWvqEawM_egbnp-TmLLTvMnyzi2W-3vYN0jZQ

import Firebase
import CoreLocation

public struct User: Codable {

    var firstname: String
    var lastname: String
    var email: String
    var phone: String
    var sellingLots: [DocumentReference]
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
    var location: GeoPoint
    var sold: Bool
    
    init(name: String, desc: String, imgs: [String], seller: String, location: GeoPoint) {
        id = UUID().uuidString
        self.name = name
        self.location = location
        description = desc
        startDate = Date() + 20//.random(in: 120...500)
        endDate = startDate + 60
        currentPrice = 0
        images = imgs
        sellerUser = seller
        winnerUser = nil
        sold = false
    }
}


