//
//  Pages.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import Foundation

struct Pages<T> {
    var values: [T] = []
    var currentPage: Int = 0
    var totalPages: Int = 1
    
    var isComplete: Bool {
        return currentPage >= totalPages
    }
    
    mutating func addPage(totalPages: Int, values: [T]) {
        self.totalPages = totalPages
        guard currentPage < totalPages else { return }
        self.currentPage += 1
        self.values.append(contentsOf: values)
    }
}
