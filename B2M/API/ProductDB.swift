//
//  ProductDB.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import Foundation

struct Pagination: Codable {
    let totalHits: Int
    let totalPages: Int
    
    private enum CodingKeys: String, CodingKey {
        case totalHits
        case totalPages
    }
}


struct ProductDBPagedResult<T: Codable>: Codable {
    let results: [T]
    let pagination: Pagination
    
    private enum CodingKeys: String, CodingKey {
        case results = "hits"
        case pagination
    }
}

protocol ProductDBFetcher {
    func fetchProducts(page: Int, completion: @escaping (ProductDBPagedResult<Product>?) -> Void)
}


class ProductDB: ProductDBFetcher {
    let baseUrl = "https://www.mamasandpapas.ae"
    
    func fetchProducts(page: Int, completion: @escaping (ProductDBPagedResult<Product>?) -> Void) {
        fetch(
            url: "\(baseUrl)/search/full/?searchString=boy&page=\(page)&hitsPerPage=10&filters",
            completion: completion
        )
    }
    
    func fetch<T: Codable>(url: String, completion: @escaping (T?) -> Void) {
        guard let url = URL(string: url) else { return completion(nil) }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
            guard
                let data = data,
                let obj = try? JSONDecoder().decode(T.self, from: data)
                else {
                    return completion(nil)
            }
            
            completion(obj)
        }
        
        task.resume()
    }

}

