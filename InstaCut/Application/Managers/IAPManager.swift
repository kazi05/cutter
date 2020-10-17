//
//  IAPManager.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import StoreKit

class IAPManager: NSObject {
    
    private(set) var products: [IAPProduct] = []
    
    private var skProducts: [SKProduct] = []
    
    private let paymentQueue = SKPaymentQueue.default()
    
    private let userDefaults = UserDefaults.standard
    
    private var purchaseCompleted: ((SKPaymentTransactionState, Error?) -> Void)?
    
    fileprivate struct Static {
        static var instance: IAPManager?
    }
    
    class var shared: IAPManager {
        
        if(Static.instance == nil) {
            Static.instance = IAPManager()
        }
        
        return Static.instance!
    }
    
    private override init() {
        super.init()
        getProducts()
    }
    
    private func getProducts() {
        let products = IAPProductKind.allCases.map { $0.rawValue }
        let request = SKProductsRequest(productIdentifiers: Set(products))
        request.delegate = self
        
        request.start()
        paymentQueue.add(self)
    }
    
    public func getProduct(by kind: IAPProductKind) -> IAPProduct? {
        return products.first(where: { $0.kind == kind })
    }
    
    public func purchase(product: IAPProductKind,
                         completion: @escaping (SKPaymentTransactionState, Error?) -> Void) {
        
        guard let purchaseProduct = skProducts.first(where: { $0.productIdentifier == product.rawValue }) else { return }
        let payment = SKPayment(product: purchaseProduct)
        paymentQueue.add(payment)
        purchaseCompleted = completion
    }
    
    public func restorePurchases() {
        paymentQueue.restoreCompletedTransactions()
    }
    
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("Transaction id: \(transaction.payment.productIdentifier) status - \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case .purchasing: break
                
            case .purchased, .restored:
                userDefaults.setValue(true, forKey: transaction.payment.productIdentifier)
                fallthrough
                
            case .failed:
                fallthrough
                
            default:
                purchaseCompleted?(transaction.transactionState, transaction.error)
                purchaseCompleted = nil
                queue.finishTransaction(transaction)
            }
        }
    }
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.skProducts = response.products
        self.products = response.products.map {
            let kind = IAPProductKind(rawValue: $0.productIdentifier) ?? .mask
            let numberFormatter = NumberFormatter()
            let locale = $0.priceLocale
            print("Purchase price locale: \($0.priceLocale), price: \($0.price)")
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = locale
            let priceString = numberFormatter.string(from: $0.price) ?? ""
            return IAPProduct(priceTitle: priceString, kind: kind)
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("IAP fetch error: \(error.localizedDescription)")
    }
}
