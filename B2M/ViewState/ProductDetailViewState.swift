//
//  ProductDetailViewState.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import Foundation

struct ProductDetailViewState {
    
    let product: Product?
    let name: String
    let description: String
    let price: Double
    let canAddToBag: Bool
    let quantity: Int
    let imageUrl: String
    let configurableAttributes: [ConfigurableAttribute]?
    
    let productDetail: ProductDetailState
    
    init(_ state: MainState) {
        switch state.productDetail {
        case .willHide(let product):
            self.product = product
        case .hide:
            self.product = nil
        case .show(let product):
            self.product = product
        case .productAdded(let product):
            self.product = product
        }
        
        canAddToBag = state.canAddToBag
        quantity = state.quantity
        name = product?.name ?? "No name"
        description = product?.description ?? "No description"
        price = product?.price ?? 0
        imageUrl = product?.smallImage ?? ""
        configurableAttributes = state.configurableAttributes
        productDetail = state.productDetail
    }
}
