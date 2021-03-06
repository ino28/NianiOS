////
////  Payment.swift
////  Nian iOS
////
////  Created by vizee on 14/11/26.
////  Copyright (c) 2014年 Sa. All rights reserved.
////
//
//import Foundation
//import StoreKit
//
//class Payment: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
//    
//    enum PayState {
//        case Purchased
//        case Cancelled
//        case VerifyFailed
//        case Failed
//        case OnPurchasing
//        case OnVerifying
//    }
//    
//    private var _callback: (PayState, AnyObject?) -> Void
//    
//    init(callback: (PayState, AnyObject?) -> Void) {
//        _callback = callback
//    }
//    
//    private func onPaymentPurchased(transaction: SKPaymentTransaction) {
//        let url = NSBundle.mainBundle().appStoreReceiptURL
//        if let _ = NSData(contentsOfURL: url!) {
//            _callback(.OnVerifying, nil)
//        }
//    }
//    
//    private func onPaymentFailed(transaction: SKPaymentTransaction) {
//        _callback(transaction.error!.code == SKErrorPaymentCancelled ? .Cancelled : .Failed, nil)
//    }
//    
//    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
//        if response.products.count == 0 {
//            return
//        }
//        let queue = SKPaymentQueue.defaultQueue()
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
//        for product: SKProduct in response.products {
//            queue.addPayment(SKPayment(product: product))
//        }
//        _callback(.OnPurchasing, nil)
//    }
//    
//    func request(request: SKRequest, didFailWithError error: NSError) {
//    }
//    
//    func requestDidFinish(request: SKRequest) {
//    }
//    
//    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction: SKPaymentTransaction in transactions {
//            switch transaction.transactionState {
//            case SKPaymentTransactionState.Purchased:
//                onPaymentPurchased(transaction)
//                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
//                SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
//                break
//            case SKPaymentTransactionState.Failed:
//                onPaymentFailed(transaction)
//                SKPaymentQueue.defaultQueue().finishTransaction(transaction)
//                SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
//                break
//            default:
//                break
//            }
//        }
//    }
//
//    func pay(productId: String) -> Bool {
//        let allowed = SKPaymentQueue.canMakePayments()
//        if allowed {
//            let request = SKProductsRequest(productIdentifiers: NSSet(object: productId) as! Set<String>)
//            request.delegate = self
//            request.start()
//        }
//        return allowed
//    }
//}
