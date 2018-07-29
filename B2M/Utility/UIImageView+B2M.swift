//
//  UIImageView+B2M.swift
//  B2M
//
//  Created by Gurcan Yavuz on 26.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//

import UIKit

extension UIImageView {
    
    
    func setProductImage(product: Product?) {
        
        if let product = product {
            if let imageUrl = product.smallImage {
                let urlString = "https://prod4.atgcdn.ae/small_light(p=listing2x,of=webp)/pub/media/catalog/product/\(imageUrl)"
                let url = URL(string: urlString)!
                let placeholderImage = UIImage(named: Constant.dummyPlaceholder)
                self.af_setImage(withURL:url, placeholderImage: placeholderImage)
            } else {
                self.image = UIImage(named:Constant.dummyPlaceholder)
            }
        } else {
            self.image = UIImage(named:Constant.dummyPlaceholder)
        }
    }
}
