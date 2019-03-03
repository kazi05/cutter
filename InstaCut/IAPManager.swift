//
//  IAPManager.swift
//  InstaCut
//
//  Created by Kazim Gajiev on 10.03.2018.
//  Copyright © 2018 Kazim Gajiev. All rights reserved.
//

import Foundation
import StoreKit

let productIdentifier = "ru.land.CutterProVersion"
var product = SKProduct()

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    private override init() {}
    
    let paymentQueue = SKPaymentQueue.default()
    
    public func setupPurchase(callback: @escaping (Bool) -> ()) {
        if SKPaymentQueue.canMakePayments() {
            paymentQueue.add(self)
            callback(true)
            return
        }
        callback(false)
    }
    
    public func getProduct() {
        let identifier: Set = [ productIdentifier ]
        
        let productRequest = SKProductsRequest(productIdentifiers: identifier)
        productRequest.delegate = self
        productRequest.start()
    }
    
    public func purchase() {
        let payment = SKPayment(product: product)
        paymentQueue.add(payment)
    }
    
}


extension IAPManager: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred: break
            case .purchasing: break
            case .failed: failed(transaction: transaction)
            case .purchased: purchased(transaction: transaction)
            case .restored: restored(transaction: transaction)
            }
        }
    }
    
    private func failed(transaction: SKPaymentTransaction) {
        if let transactionError = transaction.error as NSError? {
            if transactionError.code != SKError.paymentCancelled.rawValue {
                print(transactionError.localizedDescription)
                NotificationCenter.default.post(name: NSNotification.Name("paymentFailed"), object: nil)
            }else {
                NotificationCenter.default.post(name: NSNotification.Name("paymentCanceled"), object: nil)
            }
        }
        paymentQueue.finishTransaction(transaction)
    }
    
    private func purchased(transaction: SKPaymentTransaction) {
        let receiptValidator = ReceiptValidator()
        let result = receiptValidator.validateReceipt()
        
        switch result {
        case let .success(receipt):
            let purchase = receipt.inAppPurchaseReceipts?.filter({ $0.productIdentifier == productIdentifier }).first
            print(purchase?.productIdentifier ?? "default")
            NotificationCenter.default.post(name: NSNotification.Name("paymentPurchased"), object: nil)
        case let .error(error):
            print(error.localizedDescription)
        }
        
        paymentQueue.finishTransaction(transaction)
    }
    
    private func restored(transaction: SKPaymentTransaction) {
        paymentQueue.finishTransaction(transaction)
        NotificationCenter.default.post(name: NSNotification.Name("paymentRestored"), object: nil)
    }
    
}

extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        product = response.products.first!
        print(product.localizedTitle)
        print(product.localizedDescription)
        NotificationCenter.default.post(name: NSNotification.Name("producrGeted"), object: nil)
        isGetedProduct = true
    }
}




