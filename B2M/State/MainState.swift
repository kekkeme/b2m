//
//  MainState.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//


import ReSwift

enum ProductDetailState {
    case willHide(Product)
    case hide
    case show(Product)
    case productAdded(Product)
}

struct MainState: StateType {
    var productPages: Pages<Product> = Pages<Product>()
    
    var productDetail: ProductDetailState = .hide
    
    var products: [Product] {
        return productPages.values
    }

    var configurableAttributes: [ConfigurableAttribute] = []
    var canAddToBag: Bool = false
    var quantity: Int = 1
}

func mainReducer(action: Action, state: MainState?) -> MainState {
    var state = state ?? MainState()
    
    guard let action = action as? MainStateAction else {
        return state
    }
    
    switch action {

    case .fetchNextProductPages(let totalPages, let products):
        let values = products.filter({ product in !state.products.contains(where: { $0.id == product.id }) })
        state.productPages.addPage(totalPages: totalPages, values: values)
        
        
    case .willHideProductDetail(let product):
        state.productDetail = .willHide(product)
        // you can clear selections or cache it later
        state.quantity = 1
        state.configurableAttributes = []
        state.canAddToBag = false
    case .hideProductDetail:
        state.productDetail = .hide
    case .showProductDetail(let product):
        state.productDetail = .show(product)
        if let configurableAttributes = product.configurableAttributes {
            state.configurableAttributes = configurableAttributes
        }
    case .optionSelected(let section, let row):
        
        var options = state.configurableAttributes[section].options!
        
        //if not in stock should not change anything
        if options[row].isInStock == true {
            options = options.map { (option: Option) in
                var mutableOption = option
                mutableOption.selected = false
                return mutableOption
            }
            
            options[row].selected = true
            state.configurableAttributes[section].options = options
        }
    case .increaseQuantity:
        //you can check quantity limitations via product json response
        state.quantity = state.quantity + 1
    case .decreaseQuantity:
        //you can check quantity limitations via product json response if it can not exceed 5 you shouldnt etc.
        if state.quantity > 1 {
            state.quantity = state.quantity - 1
        }
    case .addToBag(let product):
        // you can add to bag and you store Bag in here later you can show it
        state.productDetail = .productAdded(product)
    }
    
    //you can make bag conditions check here i just check for if any option not selected
    var canAddToBag = false
    state.configurableAttributes.forEach{ attribute in
        if let _ = (attribute.options!.filter{$0.selected == true}.first) {
            canAddToBag = true
        }
    }
    
    state.canAddToBag = canAddToBag
    
    return state
}

let mainStore = Store(
    reducer: mainReducer,
    state: MainState(),
    middleware: []
)
