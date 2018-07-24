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
import UILoadControl

class ProductListViewController: UIViewController, UIScrollViewDelegate {
    
    var products: [Product] = []
    
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var productsTableView: UITableView! {
        didSet {
            productsTableView.backgroundView = UIView()
            productsTableView.backgroundView?.backgroundColor = productsTableView.backgroundColor
            productsTableView.loadControl = UILoadControl(target: self, action: #selector(loadMore(sender:)))
            
            productsTableView.rx.itemSelected
                .map { self.products[$0.row] }
                .map(MainStateAction.showProductDetail)
                .bind(onNext: mainStore.dispatch)
                .disposed(by: disposeBag)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.loadControl?.update()
    }
    
    @objc func loadMore(sender: AnyObject?) {
        mainStore.dispatch(fetchNextProductPages)
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
            guard let data = (product.description ?? "").data(using: String.Encoding.unicode) else { return }
            
            try? descriptionLabel.attributedText = NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)

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
        
        if state.fetchingData == false {
            self.productsTableView.loadControl?.endLoading()
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

