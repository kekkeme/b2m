//
//  ProductListViewState.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import Foundation

struct ProductListViewState {
    let products: [Product]
    
    let productDetail: ProductDetailState
    let fetchingData: Bool

    init(_ state: MainState) {
        products = state.products
        productDetail = state.productDetail
        fetchingData = state.fetchingData
    }
}
