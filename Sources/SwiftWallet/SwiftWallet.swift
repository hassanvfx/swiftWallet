//
//  TokensWallet.swift
//  TwinChatAI
//
//  Created by Eon Fluxor on 1/4/24.
//

import Foundation
import SwiftUI

public protocol WalletBundle: Codable,Equatable{
    var tokens:Int { get }
    var expiration:Date{ get }
}
public protocol WalletStorage{
    associatedtype BUNDLE:WalletBundle
    var purchased: [WalletToken<BUNDLE>] { get set}
    var consumed: [WalletToken<BUNDLE>] { get set}
}

public struct WalletToken<BUNDLE:WalletBundle>: Codable {
    public let count: Int
    public let expirationDate: Date
    public let bundleType: BUNDLE
    public init(count: Int, expirationDate: Date, bundleType: BUNDLE) {
        self.count = count
        self.expirationDate = expirationDate
        self.bundleType = bundleType
    }
}

public struct WalletCache<BUNDLE:WalletBundle>:WalletStorage{
    public var purchased=[WalletToken<BUNDLE>]()
    public var consumed=[WalletToken<BUNDLE>]()
    public init(purchased: [WalletToken<BUNDLE>] = [WalletToken<BUNDLE>](), consumed: [WalletToken<BUNDLE>] = [WalletToken<BUNDLE>]()) {
        self.purchased = purchased
        self.consumed = consumed
    }
}

public class WalletManager<STORAGE:WalletStorage> where STORAGE.BUNDLE: WalletBundle {

    private let purchasedTokenKey = "purchasedTokens"
    private let consumedTokenKey = "consumedTokens"

    private var storage:STORAGE
    
    public init(storage: STORAGE) {
        self.storage = storage
    }
    
    public func reset(){
        storage.purchased = []
        storage.consumed = []
    }

    public func addToken(bundle: STORAGE.BUNDLE, expiration:Date?=nil) {
        let expirationDate: Date
        let count: Int

        expirationDate = expiration ?? bundle.expiration
        count = bundle.tokens
        
        let newToken = WalletToken(count: count, expirationDate: expirationDate, bundleType: bundle)
        var currentTokens =  storage.purchased
        currentTokens.append(newToken)
        storage.purchased = currentTokens
    }

    public func consumeToken(count: Int = 1) -> Bool {
        guard canConsumeTokens(count: count) else { return false }

        var remainingToConsume = count
        var newConsumedTokens = storage.consumed

        for token in storage.purchased.sorted(by: { $0.expirationDate < $1.expirationDate }) where token.expirationDate > Date() {
            let alreadyConsumed = countConsumedTokens(bundleType: token.bundleType, expirationDate: token.expirationDate)
            let availableToConsume = token.count - alreadyConsumed

            if availableToConsume > 0 {
                let consumingNow = min(availableToConsume, remainingToConsume)
                newConsumedTokens.append(WalletToken(count: consumingNow, expirationDate: token.expirationDate, bundleType: token.bundleType))
                remainingToConsume -= consumingNow
            }

            if remainingToConsume <= 0 { break }
        }

        storage.consumed = newConsumedTokens
        return remainingToConsume <= 0
    }

    public func countConsumedTokens(bundleType: STORAGE.BUNDLE, expirationDate: Date) -> Int {
        storage.consumed.filter { $0.bundleType == bundleType && $0.expirationDate == expirationDate }
                      .map { $0.count }
                      .reduce(0, +)
    }

    public func canConsumeTokens(count: Int) -> Bool {
        let purchasedTokens = storage.purchased
        let consumedTokens = storage.consumed
        let nonExpiredTokenCount = purchasedTokens.filter { $0.expirationDate > Date() }
                                                  .map { $0.count }
                                                  .reduce(0, +)
        let consumedTokenCount = consumedTokens.map { $0.count }.reduce(0, +)

        return (nonExpiredTokenCount - consumedTokenCount) >= count
    }

    public func getBalance() -> (count: Int, closestExpirationDate: Date?) {
        let nonExpiredTokens = storage.purchased.filter { $0.expirationDate > Date() }
        let nonExpiredTokenCount = nonExpiredTokens.map { $0.count }.reduce(0, +)

        var remainingTokenCount = nonExpiredTokenCount
        for token in nonExpiredTokens.sorted(by: { $0.expirationDate < $1.expirationDate }) {
            let consumedCount = countConsumedTokens(bundleType: token.bundleType, expirationDate: token.expirationDate)
            remainingTokenCount -= min(consumedCount, token.count)
        }

        let closestExpirationDate = nonExpiredTokens.map { $0.expirationDate }.min()
        return (remainingTokenCount, closestExpirationDate)
    }
    
    public var expirationString: String? {
        // Filter out expired tokens
        let futureTokens = storage.purchased.filter { $0.expirationDate > Date() }

        // Find the most distant expiration date
        guard let latestExpirationDate = futureTokens.map({ $0.expirationDate }).max() else {
            return nil
        }

        // Convert the date to a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short

        return dateFormatter.string(from: latestExpirationDate)
    }
}
