//
//  IAPManager.swift
//  InstaCut
//
//  Created by Kazim Gadjiev on 16.10.2020.
//  Copyright © 2020 Kazim Gajiev. All rights reserved.
//

import StoreKit
import TPInAppReceipt

class IAPManager: NSObject {
    
    private(set) var products: [IAPProduct] = []
    
    private var skProducts: [SKProduct] = []
    
    private let paymentQueue = SKPaymentQueue.default()
    
    private var purchaseCompleted: ((SKPaymentTransactionState, Error?) -> Void)?
    
    private(set) var purchasedProducts = Set<IAPProductKind>()
    
    fileprivate struct Static {
        static var instance: IAPManager?
    }
    
    class var shared: IAPManager {
        
        if(Static.instance == nil) {
            Static.instance = IAPManager()
        }
        
        return Static.instance!
    }
    
    private override init() { }
    
    func receiptValidation() {
        getProducts()
        if let receipt = try? InAppReceipt.localReceipt() {
            do {
                try receipt.verify()
            }catch IARError.validationFailed(reason: .hashValidation) {
                print("Hash validation failed")
                return
            } catch IARError.validationFailed(reason: .bundleIdentifierVefirication) {
                print("Bundle identifier verification failed")
                return
            } catch IARError.validationFailed(reason: .signatureValidation) {
                print("Signature validation")
                return
            } catch {
                print("Verify unknown error")
                return
            }
            
            for purchase in receipt.purchases {
                guard let product = IAPProductKind(rawValue: purchase.productIdentifier) else {
                    continue
                }
                purchasedProducts.insert(product)
            }
        }
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
    
    public func restorePurchases(completion: @escaping (SKPaymentTransactionState, Error?) -> Void) {
        paymentQueue.restoreCompletedTransactions()
        purchaseCompleted = completion
    }
    
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("Transaction id: \(transaction.payment.productIdentifier) status - \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case .purchasing: break
                
            case .purchased, .restored:
                guard let product = IAPProductKind(rawValue: transaction.payment.productIdentifier) else {
                    fallthrough
                }
                purchasedProducts.insert(product)
                fallthrough
                
            case .failed:
                if let error = transaction.error {
                    print("Transaction error: \(error)")
                }
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
