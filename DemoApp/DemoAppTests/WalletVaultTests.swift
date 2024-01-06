//
//  TwinChatAITests.swift
//  TwinChatAITests
//
//  Created by Eon Fluxor on 1/31/23.
//

import XCTest
import SwiftWallet
import SwiftUI


class WalletVaultTests: XCTestCase {
    typealias Token=WalletToken<BundleType>
    typealias Wallet=WalletManager<WalletVault<BundleType>>
    var wallet: Wallet!
    let secureVault = WalletVault<BundleType>()
    override func setUp() {
        super.setUp()
        wallet = WalletManager(storage: secureVault)
    }
    
    override func tearDown() {
        // Clean up or reset UserDefaults after each test
        super.tearDown()
        wallet.reset()
    }
    
    func testConsumeSingleToken() {
        // Setup
        let bundle = BundleType.week
        wallet.addToken(bundle: bundle)
        
        // Action
        let result = wallet.consumeToken()
        
        // Expected Result
        XCTAssertTrue(result, "Should be able to consume a single token")
        XCTAssertEqual(wallet.getBalance().count, bundle.tokens - 1, "\(bundle.tokens - 1) tokens should remain")
    }
    
    func testConsumeTokensUpToBundleLimit() {
        // Setup
        let bundle = BundleType.month
        wallet.addToken(bundle: bundle)
        
        // Action
        var allConsumed = true
        for _ in 1...bundle.tokens {
            allConsumed = allConsumed && wallet.consumeToken()
        }
        let consumeExtra = wallet.consumeToken()
        
        // Expected Result
        XCTAssertTrue(allConsumed, "Should consume all \(bundle.tokens) tokens")
        XCTAssertFalse(consumeExtra, "Should not be able to consume beyond limit")
    }
    
    func testConsumeTokensFromMultipleBundles() {
        // Setup
        let bundle1 = BundleType.week
        let bundle2 = BundleType.month
        wallet.addToken(bundle: bundle1)
        wallet.addToken(bundle: bundle2)
        
        // Action
        for _ in 1...bundle1.tokens {
            _ = wallet.consumeToken()
        }
        let remainingTokens = wallet.getBalance().count
        
        // Expected Result
        XCTAssertEqual(remainingTokens, bundle2.tokens, "400 tokens should remain from the second bundle")
    }
    
    func testConsumeExpiredToken() {
        // Setup
        wallet.addToken(bundle: .day, expiration: Date())
        // Simulate time passage or mock date to be after expiration
        sleep(1)
        // Action
        let result = wallet.consumeToken()
        
        // Expected Result
        XCTAssertFalse(result, "Should not be able to consume expired token")
    }
    
    func testConsumeMoreTokensThanAvailable() {
        // Setup
        let bundle = BundleType.week
        wallet.addToken(bundle: .week)
        for _ in 1...bundle.tokens + 1 {
            _ = wallet.consumeToken()
        }
        
        // Action
        let result = wallet.consumeToken(count: 10)
        
        // Expected Result
        XCTAssertFalse(result, "Should not be able to consume more tokens than available")
    }
    
    func testConsumeTokensFromMultipleBundles2() {
        // Setup
        let bundle1 = BundleType.week
        let bundle2 = BundleType.month
        wallet.addToken(bundle: bundle1)
        wallet.addToken(bundle: bundle2)
        
        // Action
        let fromBundle2 = bundle2.tokens / 2
        let remainder = bundle2.tokens - fromBundle2
        for _ in 1...bundle1.tokens + fromBundle2 {
            _ = wallet.consumeToken()
        }
        let remainingTokens = wallet.getBalance().count
        
        // Expected Result
        XCTAssertEqual(remainingTokens, remainder, "\(remainder) tokens should remain from the second bundle")
    }
    
    func testConsumeTokensFromMultipleBundlesUpToZero() {
        // Setup
        let bundle1 = BundleType.week
        let bundle2 = BundleType.month
        wallet.addToken(bundle: bundle1)
        wallet.addToken(bundle: bundle2)
        
        // Action
        for _ in 1...bundle1.tokens +  bundle2.tokens {
            _ = wallet.consumeToken()
        }
        let remainingTokens = wallet.getBalance().count
        
        // Expected Result
        XCTAssertEqual(remainingTokens, 0, "\(0) tokens should remain from the second bundle")
        
        let result = wallet.consumeToken(count: 10)
        XCTAssertFalse(result, "no purchase no credit")
        
    }
    
    func testCanPurchaseFalse() {
        // Setup
        let bundle1 = BundleType.week
        let bundle2 = BundleType.month
        wallet.addToken(bundle: bundle1)
        wallet.addToken(bundle: bundle2)
        
        // Action
        for _ in 1...bundle1.tokens +  bundle2.tokens {
            _ = wallet.consumeToken()
        }
        let remainingTokens = wallet.getBalance().count
        
        // Expected Result
        XCTAssertEqual(remainingTokens, 0, "\(0) tokens should remain from the second bundle")
        
        let result = wallet.canConsumeTokens(count: 1)
        XCTAssertFalse(result, "no purchase no credit")
        
    }
    
    func testCanPurchaseTrue() {
        // Setup
        let bundle1 = BundleType.week
        let bundle2 = BundleType.month
        wallet.addToken(bundle: bundle1)
        wallet.addToken(bundle: bundle2)
        
        // Action
        for _ in 1...bundle1.tokens {
            _ = wallet.consumeToken()
        }
        let remainingTokens = wallet.getBalance().count
        
        // Expected Result
        XCTAssertEqual(remainingTokens, bundle2.tokens, "\(bundle2.tokens) tokens should remain from the second bundle")
        
        for _ in 1...bundle2.tokens {
            let result = wallet.consumeToken()
            XCTAssertTrue(result, "purchase must work")
        }
        
        let result = wallet.canConsumeTokens(count: 1)
        XCTAssertFalse(result, "no purchase no credit")
        
    }
    // Test Consume Tokens with Different Counts in Random Order
    func testRandomOrderConsumption() {
        // Setup
        let bundleWeek = BundleType.week
        let bundleMonth = BundleType.month
        wallet.addToken(bundle: bundleWeek)   // Adds bundleWeek.tokens tokens
        wallet.addToken(bundle: bundleMonth)  // Adds bundleMonth.tokens tokens, total tokens = bundleWeek.tokens + bundleMonth.tokens
        
        // Initial Assertion
        let initialTotalTokens = bundleWeek.tokens + bundleMonth.tokens
        XCTAssertEqual(wallet.getBalance().count, initialTotalTokens, "Initial balance should be \(initialTotalTokens) tokens")
        
        // Action and Expected Result
        let randomCounts = [3, 15, 7, 20, 1, 5] // Example random counts
        var expectedRemainingTokens = initialTotalTokens // Starting with initial total tokens
        
        for count in randomCounts {
            let result = wallet.consumeToken(count: count)
            expectedRemainingTokens -= count
            
            // Verify if consumption was successful
            XCTAssertTrue(result, "Should be able to consume \(count) tokens")
            XCTAssertEqual(wallet.getBalance().count, expectedRemainingTokens, "After consuming \(count) tokens, \(expectedRemainingTokens) tokens should remain")
        }
        
        // Verify that no more tokens can be consumed after balance reaches zero
        
        let consumeAll = wallet.consumeToken(count: expectedRemainingTokens)
        XCTAssertTrue(consumeAll, "Should be able to consume additional tokens")
        
        let additionalConsumption = 1
        let finalResult = wallet.consumeToken(count: additionalConsumption)
        XCTAssertFalse(finalResult, "Should not be able to consume additional tokens when balance is zero or less")
    }
    
}
