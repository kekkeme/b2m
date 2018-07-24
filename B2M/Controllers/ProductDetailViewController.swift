//
//  ProductDetailViewController.swift
//  B2M
//
//  Created by Gurcan Yavuz on 22.07.2018.
//  Copyright © 2018 Bring2Me. All rights reserved.
//


import ReSwift
import RxCocoa
import RxSwift
import CRNotifications


class ProductDetailViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var addToBagButton: UIButton!
    @IBOutlet weak var skuLabel: UILabel!
    
    private let productImageViewHeight: CGFloat = 500
    private var productView: UIView!
    
    let disposeBag = DisposeBag()
    var configurableAttributes: [ConfigurableAttribute] = []
    var canAddToBag = false
    
    @IBAction func addToBagButtonPressed(_ sender: Any) {
        guard canAddToBag == true else {
            CRNotifications.showNotification(type: .error, title: NSLocalizedString("Please select size", comment: ""), message:  NSLocalizedString("You must select size for adding to bag", comment: ""), dismissDelay: 3)
            return
        }
        
        if case let .show(product) = mainStore.state.productDetail {
            mainStore.dispatch(MainStateAction.addToBag(product))
        }
    }
    
    @IBAction func decreaseQuantityButtonPressed(_ sender: Any) {
        
        guard let _ = (configurableAttributes[0].options!.filter{$0.selected == true}.first) else {
            CRNotifications.showNotification(type: .error, title: NSLocalizedString("Please select size", comment: ""), message:  NSLocalizedString("First you must select appropriate size to change quantity", comment: ""), dismissDelay: 3)
            return
        }
        
        mainStore.dispatch(MainStateAction.decreaseQuantity)
    }
    
    @IBAction func increaseQuantityButtonPressed(_ sender: Any) {
        
        guard let _ = (configurableAttributes[0].options!.filter{$0.selected == true}.first) else {
            CRNotifications.showNotification(type: .error, title: NSLocalizedString("Please select size", comment: ""), message:  NSLocalizedString("First you must select appropriate size to change quantity", comment: ""), dismissDelay: 3)
            return
        }
        
        mainStore.dispatch(MainStateAction.increaseQuantity({
            CRNotifications.showNotification(type: .error, title: NSLocalizedString("Not enough", comment: ""), message:  NSLocalizedString("We dont have more than that quantity", comment: ""), dismissDelay: 3)
        }))
    }
    
    @IBOutlet weak var categorySizeTableView: UITableView! {
        didSet {
            categorySizeTableView.backgroundView = UIView()
            categorySizeTableView.backgroundView?.backgroundColor = categorySizeTableView.backgroundColor
            
            categorySizeTableView.rx.itemSelected
                .map { item in
                    return (item.section, item.row, {
                        CRNotifications.showNotification(type: .error, title: NSLocalizedString("Not in stock", comment: ""), message:  NSLocalizedString("We dont have enough stock for that option", comment: ""), dismissDelay: 3)
                    })
                }
                .map(MainStateAction.optionSelected)
                .bind(onNext: mainStore.dispatch)
                .disposed(by: disposeBag)
            
            categorySizeTableView.rx.willDisplayCell
                .filter { $1.row == mainStore.state.products.count - 1 }
                .map { _ in fetchNextProductPages }
                .bind(onNext: mainStore.dispatch)
                .disposed(by: disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProductView()
        updateProductView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self, transform: {
            $0.select(ProductDetailViewState.init)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
        
        if case let .show(product) = mainStore.state.productDetail {
            //You can send different analytic events
            mainStore.dispatch(MainStateAction.willHideProductDetail(product))
        }
        
        if case let .productAdded(product) = mainStore.state.productDetail {
            //You can send different analytic events
            mainStore.dispatch(MainStateAction.willHideProductDetail(product))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        mainStore.dispatch(MainStateAction.hideProductDetail)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateProductView()
    }
    
    
    func setupProductView() {
        productView = categorySizeTableView.tableHeaderView
        categorySizeTableView.tableHeaderView = nil
        categorySizeTableView.addSubview(productView)
        categorySizeTableView.contentInset = UIEdgeInsets(top: productImageViewHeight, left: 0, bottom: 0, right: 0)
        categorySizeTableView.contentOffset = CGPoint(x: 0, y: -productImageViewHeight)
    }
    
    func updateProductView() {
        var productImageRect = CGRect(
            x: 0, y: -productImageViewHeight,
            width: categorySizeTableView.bounds.width, height: productImageViewHeight
        )
        
        if categorySizeTableView.contentOffset.y < -productImageViewHeight {
            productImageRect.origin.y = categorySizeTableView.contentOffset.y
            productImageRect.size.height = -categorySizeTableView.contentOffset.y
        }
        
        productView.frame = productImageRect
    }
}

extension ProductDetailViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = ProductDetailViewState
    
    func newState(state: ProductDetailViewState) {
        
        if case .productAdded = state.productDetail {
            CRNotifications.showNotification(type: .success, title: NSLocalizedString("Production", comment: ""), message:  NSLocalizedString("You production successfully added to bag", comment: ""), dismissDelay: 3)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        skuLabel.text = ""
        if let configurableAttributes = state.configurableAttributes {
            self.configurableAttributes = configurableAttributes
            if let option = (self.configurableAttributes[0].options!.filter{$0.selected == true}.first) {
                skuLabel.text = option.simpleProductSkus![0]
            }
        }
        
        title = state.name
        nameLabel.text = state.name
        descriptionLabel.text = state.description
        priceLabel.text = "Price: \(state.price)"
        quantityLabel.text = "\(state.quantity)"
        canAddToBag = state.canAddToBag
        if canAddToBag == true {
            addToBagButton.setTitleColor(UIColor.blue, for: .normal)
        } else {
            addToBagButton.setTitleColor(UIColor.b2mGrayColor(), for: .normal)
        }
        
        if let product = state.product {
            if let imageUrl = product.smallImage {
                let urlString = "https://prod4.atgcdn.ae/small_light(p=listing2x,of=webp)/pub/media/catalog/product/\(imageUrl)"
                let url = URL(string: urlString)!
                let placeholderImage = UIImage(named: Constant.dummyPlaceholder)
                productImageView.af_setImage(withURL:url, placeholderImage: placeholderImage)
            } else {
                productImageView.image = UIImage(named:Constant.dummyPlaceholder)
            }
        } else {
            productImageView.image = UIImage(named:Constant.dummyPlaceholder)
        }
        
        categorySizeTableView.reloadData()
    }
}


class OptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var option: Option? {
        didSet {
            
            guard let option = option else { return }
            
            nameLabel.textColor = UIColor.b2mGrayColor()
            if option.selected == true {
                nameLabel.textColor = UIColor.b2mBlackColor()
            }
            
            if option.isInStock == false {
                nameLabel.text = "\(option.label ?? "") Not in stock"
            } else {
                nameLabel.text = "\(option.label ?? "") (\(option.sizeInStock))"
            }
        }
    }
}

extension ProductDetailViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.configurableAttributes.count > 0 else {
            return 1
        }
        
        return self.configurableAttributes.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.configurableAttributes.count > 0 else {
            return 0
        }
        
        return self.configurableAttributes[section].options?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Views.optionTableViewCell) as? OptionTableViewCell else {
            return UITableViewCell()
        }
        
        cell.option = self.configurableAttributes[indexPath.section].options![indexPath.row]
        cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        cell.selectionStyle = .none
        
        return cell
    }
}

