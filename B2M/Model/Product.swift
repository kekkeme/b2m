//
//  Product.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//


import Foundation

struct Product: Codable {
    let id: Int?
    let smallImage: String?
    let description: String?
    let name: String?
    let price: Double?
    let configurableAttributes: [ConfigurableAttribute]?
    
    private enum CodingKeys: String, CodingKey {
        case id = "productId"
        case smallImage
        case description
        case name
        case price
        case configurableAttributes
    }
}
