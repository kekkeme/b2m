//
//  MainStateTests.swift
//  B2MTests
//
//  Created by Gurcan Yavuz on 24.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import ReSwift

import XCTest
@testable import B2M

class MainStateTests: XCTestCase {
    
    
    func lint(_ action: MainStateAction) -> () -> Void {
        switch action {
        case .fetchNextProductPages(_, _):
            return testFetchNextProductPages
        case .fetchingNextProductPages:
            return testFetchingNextProductPages
        case .showProductDetail(_):
            return testShowProductDetail
        case .willHideProductDetail(_):
            return testWillHideProductDetail
        case .hideProductDetail:
            return testHideProductDetail
        case .optionSelected(_, _, _):
            return testOptionSelected
        case .increaseQuantity(_):
            return testIncreaseQuantity
        case .decreaseQuantity:
            return testDecreaseQuantity
        case .addToBag(_):
            return testAddToBag
        }
        
    }

    func makeStore() -> Store<MainState> {
        return Store(
            reducer: mainReducer,
            state: MainState(),
            middleware: []
        )
    }

    func testFetchNextProductPages() {
        
        //GIVEN state is initial
        //WHEN  fetched 2 pages from server
        //THEN  product size, page number must be valid
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        let action = MainStateAction.fetchNextProductPages(
            totalPages: 10,
            products: [
                Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute),
                Product(id: 2, smallImage: "smallImage", description: "product 2", name: "product 2", price: 10, configurableAttributes: configurableAttribute),
                Product(id: 3, smallImage: "smallImage", description: "product 3", name: "product 3", price: 10, configurableAttributes: configurableAttribute),
            ]
        )
 
        let action2 = MainStateAction.fetchNextProductPages(
            totalPages: 11,
            products: [
                Product(id: 4, smallImage: "smallImage", description: "product 1", name: "product 4", price: 10, configurableAttributes: configurableAttribute),
                Product(id: 5, smallImage: "smallImage", description: "product 2", name: "product 5", price: 10, configurableAttributes: configurableAttribute),
                Product(id: 6, smallImage: "smallImage", description: "product 3", name: "product 6", price: 10, configurableAttributes: configurableAttribute),
                ]
        )
        
        let state = mainReducer(action: action, state: nil)
        let state2 = mainReducer(action: action2, state: state)

        XCTAssert(state2.productPages.totalPages == 11)
        XCTAssert(state2.productPages.currentPage == 2)
        XCTAssert(state2.productPages.values.count == 6)
        XCTAssert(state2.productPages.values[0].name == "product 1")
        XCTAssert(state2.productPages.values[1].name == "product 2")
        XCTAssert(state2.productPages.values[2].name == "product 3")
        XCTAssert(state2.productPages.values[3].name == "product 4")
        XCTAssert(state2.productPages.values[4].name == "product 5")
        XCTAssert(state2.productPages.values[5].name == "product 6")
    }
    
    
    func testFetchingNextProductPages() {
        
        //GIVEN state is initial
        //WHEN  start fetching data from server
        //THEN  fetchingData property of state must be true
        
        let action = MainStateAction.fetchingNextProductPages
        let state = mainReducer(action: action, state: nil)
        
        
        guard state.fetchingData == true else {
            return XCTFail()
        }
        
    }
    
    func testShowProductDetail() {
        
        //GIVEN state is initial
        //WHEN  user select Product to go Product detail page
        //THEN  User must select true Product detail
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        let action = MainStateAction.showProductDetail(
            Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        )
        
        let state = mainReducer(action: action, state: nil)
        
        guard case let .show(product) = state.productDetail else {
            return XCTFail()
        }
        
        XCTAssert(product.name == "product 1")
    }
    
    
    
    func testWillHideProductDetail() {
        
        //GIVEN state is initial
        //WHEN  user return from product detail page to product list page
        //THEN  productDetail state must be willHide,
        //      state quantity value reset to 1,
        //      state can Add to bag must reset to be false
        //      state product size attributes must reset to empty array
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        let prod = Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        let action = MainStateAction.showProductDetail(
            prod
        )
        
        var state = mainReducer(action: action, state: nil)
        state = mainReducer(action: MainStateAction.willHideProductDetail(prod), state: state)
        

        guard case .willHide(_) = state.productDetail else {
            return XCTFail()
        }
        
        guard state.quantity == 1 else {
            return XCTFail()
        }
        
        guard state.configurableAttributes.count == 0 else {
            return XCTFail()
        }
        
    }
    
    func testHideProductDetail() {
        
        //GIVEN state is initial
        //WHEN  user return from product detail page to product list page
        //THEN  product detail state must be hide
        
        let action = MainStateAction.hideProductDetail
        let state = mainReducer(action: action, state: nil)
        
        
        guard case .hide = state.productDetail else {
            return XCTFail()
        }
        
    }
    
    
    func testOptionSelected() {
        
        //GIVEN state is product detail page
        //WHEN   isInStock true option
        //THEN  quantity must reset to 1,
        //      option selected property must be true
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        var action = MainStateAction.showProductDetail(
            Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        )
        
        var state = mainReducer(action: action, state: nil)
        
        action = MainStateAction.optionSelected(0, 1, {})
        state = mainReducer(action: action, state: state)
        
        XCTAssert(state.configurableAttributes[0].options![1].selected == true)
        XCTAssert(state.quantity == 1)
        
    }
    
    func testIncreaseQuantity() {
        //GIVEN state is product detail page
        //WHEN   user increase quantity of product and quantity value is 1
        //THEN  quantity must be 2
        //      option selected property must be true
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        var action = MainStateAction.showProductDetail(
            Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        )
        
        var state = mainReducer(action: action, state: nil)
        
        action = MainStateAction.optionSelected(0, 1, {})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        
        XCTAssert(state.quantity == 2)
        
    }
    
    func testDecreaseQuantity() {
        //GIVEN state is product detail page
        //WHEN   user decrease quantity of product quantity initial value is 4
        //THEN  quantity must be 3
        //      option selected property must be true
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        var action = MainStateAction.showProductDetail(
            Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        )
        
        var state = mainReducer(action: action, state: nil)
        
        action = MainStateAction.optionSelected(0, 1, {})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.decreaseQuantity
        state = mainReducer(action: action, state: state)
        
        XCTAssert(state.quantity == 3)
    }
    
    func testAddToBag() {
        //GIVEN state is initial, option selected
        //WHEN  user add product to bag
        //THEN  state will be accordingly
        
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        let product = Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        var action = MainStateAction.showProductDetail(
            product
        )
        
        var state = mainReducer(action: action, state: nil)
        
        action = MainStateAction.addToBag(product)
        state = mainReducer(action: action, state: state)
        
        
        guard case .productAdded(_) = state.productDetail else {
            return XCTFail()
        }
    }
    
    //Business case scenarios
    func testWhenUserSelectNotInStockOptionOptionMustNotBeSelected() {
        
        //GIVEN state user in product detail
        //WHEN  user selects not in stock option
        //THEN  those option should not be selected
     
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        var action = MainStateAction.showProductDetail(
            Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        )
        
        var state = mainReducer(action: action, state: nil)
        
        //user selects first option not in stock
        action = MainStateAction.optionSelected(0, 0, {})
        state = mainReducer(action: action, state: state)
        
        XCTAssert(state.configurableAttributes[0].options![0].selected == false)
    }
    
    func testWhenUserIncreaseQuantityOfProductWhenThereIsNotEnoughQuantityInStore() {
        
        //GIVEN state user in product detail
        //WHEN  user try to increase quantity when quantity is 3 and when stock is 3
        //THEN  user should not increase quantity
        var options:[Option] = []
        options.append(Option(optionId: 1, label: "option 1", simpleProductSkus: ["1"], isInStock: false, selected: false, sizeInStock: 0))
        options.append(Option(optionId: 2, label: "option 2", simpleProductSkus: ["2"], isInStock: true, selected: false, sizeInStock: 5))
        options.append(Option(optionId: 3, label: "option 3", simpleProductSkus: ["3"], isInStock: true, selected: false, sizeInStock: 3))
        
        var configurableAttribute:[ConfigurableAttribute] = []
        configurableAttribute.append(ConfigurableAttribute(code:"sizeCode", options: options))
        
        var action = MainStateAction.showProductDetail(
            Product(id: 1, smallImage: "smallImage", description: "product 1", name: "product 1", price: 10, configurableAttributes: configurableAttribute)
        )
        
        var state = mainReducer(action: action, state: nil)
        
        // selected option has 3 quantity in stock
        action = MainStateAction.optionSelected(0, 2, {})
        state = mainReducer(action: action, state: state)
        //i must check sizeInStock because i generate it with random number
        let sizeInStock = state.configurableAttributes[0].options![2].sizeInStock
        for _ in 0..<sizeInStock {
            action = MainStateAction.increaseQuantity({})
            state = mainReducer(action: action, state: state)
        }
        
        //those quantity methods must not work
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)
        action = MainStateAction.increaseQuantity({})
        state = mainReducer(action: action, state: state)

        XCTAssert(state.configurableAttributes[0].options![2].selected == true)
        XCTAssert(state.quantity == sizeInStock)
    }
    
}
