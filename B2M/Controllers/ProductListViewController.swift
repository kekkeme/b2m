//
//  ProductListController.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//


import Foundation
import UIKit
import ReSwift
import RxCocoa
import RxSwift
import AlamofireImage


class ProductListViewController: UIViewController {
    
    var products: [Product] = []
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var productsTableView: UITableView! {
        didSet {
            productsTableView.backgroundView = UIView()
            productsTableView.backgroundView?.backgroundColor = productsTableView.backgroundColor
            
            productsTableView.rx.itemSelected
                .map { self.products[$0.row] }
                .map(MainStateAction.showProductDetail)
                .bind(onNext: mainStore.dispatch)
                .disposed(by: disposeBag)
            
            productsTableView.rx.willDisplayCell
                .filter { $1.row == mainStore.state.products.count - 1 }
                .map { _ in fetchNextProductPages }
                .bind(onNext: mainStore.dispatch)
                .disposed(by: disposeBag)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self, transform: {
            $0.select(ProductListViewState.init)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
}


class ProductListTableViewCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .none : .disclosureIndicator
    }
    
    var product: Product? {
        didSet {
            
            guard let product = product else { return }
            
            if let imageUrl = product.smallImage {
                let urlString = "https://prod4.atgcdn.ae/small_light(p=listing2x,of=webp)/pub/media/catalog/product/\(imageUrl)"
                let url = URL(string: urlString)!
                let placeholderImage = UIImage(named: Constant.dummyPlaceholder)
                productImageView.af_setImage(withURL:url, placeholderImage: placeholderImage)
            } else {
                productImageView.image = UIImage(named:Constant.dummyPlaceholder)
            }
            
            nameLabel.text = product.name
            descriptionLabel.text = product.description ?? ""
            priceLabel.text = "Price: \(product.price ?? 0)"
        }
    }
}


extension ProductListViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = ProductListViewState
    
    func newState(state: ProductListViewState) {
        products = state.products
        productsTableView.reloadData()
        
        if case .show = state.productDetail {
            self.performSegue(withIdentifier: Views.showProductDetailViewController, sender: nil)
        }
    }
}

extension ProductListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Views.productListTableViewCell) as? ProductListTableViewCell else {
            return UITableViewCell()
        }
        
        cell.product = products[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        cell.selectionStyle = .none
        
        return cell
    }
}

