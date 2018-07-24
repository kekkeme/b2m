//
//  MainStateAction.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import ReSwift

enum MainStateAction: Action {
    
    case fetchNextProductPages(totalPages: Int, products: [Product])
    case fetchingNextProductPages
    
    case showProductDetail(Product)
    case willHideProductDetail(Product)
    case hideProductDetail
    case optionSelected(Int, Int, () -> Void  )
    case increaseQuantity(() -> Void)
    case decreaseQuantity
    case addToBag(Product)
}
