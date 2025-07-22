import Foundation
import StoreKit

/// Class for managing StoreKit
class StoreKitManager: NSObject {
    static let shared = StoreKitManager()
    
    private var useStoreKit2: Bool = false
    private var isObserving: Bool = false
    
    // StoreKit 1
    private var transactionObserver: SKPaymentTransactionObserver?
    
    // StoreKit 2
    private var updateListenerTask: Task<Void, Error>?
    
    private override init() {
        super.init()
    }
    
    /// Start StoreKit observation
    func startObserving(useStoreKit2: Bool) {
        self.useStoreKit2 = useStoreKit2
        
        if useStoreKit2 {
            startStoreKit2Observing()
        } else {
            startStoreKit1Observing()
        }
        
        isObserving = true
    }
    
    /// Stop StoreKit observation
    func stopObserving() {
        if useStoreKit2 {
            stopStoreKit2Observing()
        } else {
            stopStoreKit1Observing()
        }
        
        isObserving = false
    }
    
    /// Send receipt
    func sendReceipt() async {
        if useStoreKit2 {
            if #available(iOS 15.0, *) {
                await sendStoreKit2Receipt()
            } else {
                print("[MonetaiSDK] StoreKit 2 is only supported on iOS 15.0 or later.")
                await sendStoreKit1Receipt()
            }
        } else {
            await sendStoreKit1Receipt()
        }
    }
    
    // MARK: - StoreKit 1
    private func startStoreKit1Observing() {
        guard !isObserving else { return }
        
        transactionObserver = StoreKit1TransactionObserver()
        SKPaymentQueue.default().add(transactionObserver!)
    }
    
    private func stopStoreKit1Observing() {
        if let observer = transactionObserver {
            SKPaymentQueue.default().remove(observer)
            transactionObserver = nil
        }
    }
    
    private func sendStoreKit1Receipt() async {
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            print("[MonetaiSDK] StoreKit 1 receipt not found.")
            return
        }
        
        let receiptString = receiptData.base64EncodedString()
        await sendReceiptToServer(receiptString: receiptString)
    }
    
    // MARK: - StoreKit 2
    private func startStoreKit2Observing() {
        guard !isObserving else { return }
        
        if #available(iOS 15.0, *) {
            updateListenerTask = listenForTransactions()
        } else {
            print("[MonetaiSDK] StoreKit 2 is only supported on iOS 15.0 or later.")
        }
    }
    
    private func stopStoreKit2Observing() {
        updateListenerTask?.cancel()
        updateListenerTask = nil
    }
    
    @available(iOS 15.0, *)
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                await self.handleTransactionUpdate(result)
            }
        }
    }
    
    @available(iOS 15.0, *)
    private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
        let transaction: Transaction
        
        do {
            transaction = try result.payloadValue
        } catch {
            print("[MonetaiSDK] StoreKit 2 transaction verification failed: \(error)")
            return
        }
        
        // Mapping and receipt transmission upon transaction completion
        if transaction.revocationDate == nil {
            let originalTransactionId = String(transaction.originalID)
            await handleTransactionCompletion(transactionId: originalTransactionId)
        }
    }
    
    @available(iOS 15.0, *)
    private func sendStoreKit2Receipt() async {
        // Use app receipt in StoreKit 2
        guard let receiptURL = Bundle.main.appStoreReceiptURL,
              let receiptData = try? Data(contentsOf: receiptURL) else {
            print("[MonetaiSDK] StoreKit 2 receipt not found.")
            return
        }
        
        let receiptString = receiptData.base64EncodedString()
        await sendReceiptToServer(receiptString: receiptString)
    }
    
    // MARK: - Transaction Completion Handler
    internal func handleTransactionCompletion(transactionId: String) async {
        guard let sdkKey = MonetaiSDK.shared.currentSDKKey,
              let userId = MonetaiSDK.shared.currentUserId,
              let bundleId = Bundle.main.bundleIdentifier else {
            print("[MonetaiSDK] Transaction processing failed: Insufficient SDK initialization information")
            return
        }
        
        // 1. Transaction ID mapping
        do {
            try await APIRequests.mapTransactionToUser(
                transactionId: transactionId,
                bundleId: bundleId,
                sdkKey: sdkKey,
                userId: userId
            )
            print("[MonetaiSDK] Transaction mapping successful: \(transactionId)")
        } catch {
            print("[MonetaiSDK] Transaction mapping failed: \(error)")
        }
        
        // 2. Receipt verification and upload
        await sendReceipt()
    }
    
    // MARK: - Receipt Server
    private func sendReceiptToServer(receiptString: String) async {
        guard let sdkKey = MonetaiSDK.shared.currentSDKKey,
              let userId = MonetaiSDK.shared.currentUserId,
              let bundleId = Bundle.main.bundleIdentifier else {
            print("[MonetaiSDK] Receipt upload failed: Insufficient SDK initialization information")
            return
        }
        
        do {
            try await APIRequests.validateReceipt(
                receiptData: receiptString,
                bundleId: bundleId,
                sdkKey: sdkKey,
                userId: userId
            )
            print("[MonetaiSDK] Receipt upload successful: \(receiptString.prefix(20))...")
        } catch {
            print("[MonetaiSDK] Receipt upload failed: \(error)")
        }
    }
}

// MARK: - StoreKit 1 Transaction Observer
class StoreKit1TransactionObserver: NSObject, SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                // Process transaction upon purchase completion
                let originalTransactionId = transaction.original?.transactionIdentifier ?? transaction.transactionIdentifier
                if let transactionId = originalTransactionId {
                    Task {
                        await StoreKitManager.shared.handleTransactionCompletion(transactionId: transactionId)
                    }
                }
            case .failed:
                break
            case .deferred, .purchasing:
                break
            @unknown default:
                break
            }
        }
    }
} 