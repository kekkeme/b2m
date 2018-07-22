//
//  ActionCreators.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import ReSwift

fileprivate func fetchNextUpcomingProductsPage(state: MainState, store: Store<MainState>) -> Action? {
    guard !state.productPages.isComplete else { return nil }
    
    ProductDB().fetchProducts(page: mainStore.state.productPages.currentPage + 1) { result in
        guard let result = result else { return }
        
        DispatchQueue.main.async {
            mainStore.dispatch(
                MainStateAction.fetchNextProductPages(
                    totalPages: result.pagination.totalPages,
                    products: result.results
                )
            )
        }
    }
    
    return nil
}

func fetchNextProductPages(state: MainState, store: Store<MainState>) -> Action? {
    return fetchNextUpcomingProductsPage(state: state, store: store)
}
