//
//  ConfigurableAttribute.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import Foundation

struct Option: Codable {
    let optionId: Int?
    let label: String?
    let simpleProductSkus: [String]?
    let isInStock: Bool
    var selected: Bool = false
    var sizeInStock: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case optionId
        case label
        case simpleProductSkus
        case isInStock
    }
}

struct ConfigurableAttribute: Codable {
    let code: String?
    var options: [Option]?
    
    private enum CodingKeys: String, CodingKey {
        case code
        case options
    }
}
