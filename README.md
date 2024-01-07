# SwiftWallet

![image](https://github.com/hassanvfx/swiftWallet/assets/425926/714f9297-6eec-420d-be84-536943b00b60)


SwiftWallet is a powerful library for iOS applications that provides an
encrypted store for an app wallet, leveraging the `securevault` library
for secure data storage.

# Features:

- **Encrypted Storage**: Integrates with `securevault`
  (<https://github.com/hassanvfx/securevault>) for secure wallet
  storage.

- **Comprehensive Wallet Operations**: Supports adding, consuming
  tokens, checking balances, and assessing token consumption
  eligibility.

- **Bundle Tokens Support**: Handles tokens in bundles with specific
  expiration dates.

- **Optimized Token Consumption**: Efficiently computes unexpired token
  bundles to maximize token usage.

- **Robust Testing Framework**: Includes extensive test cases ensuring
  reliability.

- **Caching Solutions**: Offers both a simple memory cache and a
  `securevault` implementation.

- **Sample Implementations**: Provides examples for memory cache and
  `securevault` use.

# Practical Implementation Guide:

Based on the unit tests included with SwiftWallet, this guide outlines
key usage scenarios for the library.

## Setting Up a Wallet Cache

``` swift
import SwiftUI
@testable import SwiftWallet

class YourClass {
    typealias Wallet = WalletManager<WalletCache<BundleType>>
    var wallet: Wallet!
    let cache = WalletCache<BundleType>()

    init() {
        wallet = WalletManager(storage: cache)
        // Additional setup...
    }
}
```

## Adding and Consuming Tokens

Adding tokens to a wallet and consuming them is straightforward:

``` swift
func addAndConsumeTokens() {
    // Adding a week-long token bundle
    let weekBundle = BundleType.week
    wallet.addToken(bundle: weekBundle)

    // Consuming a single token
    let consumeResult = wallet.consumeToken()
    if consumeResult {
        print("Token consumed successfully")
    } else {
        print("Failed to consume token")
    }
}
```

## Checking Token Balance

To check the current balance of tokens in the wallet:

``` swift
func checkTokenBalance() {
    let balance = wallet.getBalance()
    print("Current token count: \(balance.count)")
}
```

## Handling Token Expiration

SwiftWallet allows for easy management of token expiration:

``` swift
func handleTokenExpiration() {
    wallet.addToken(bundle: .day, expiration: Date())
    // Simulate time passage or mock date to be after expiration
    // Check for token consumption
    if !wallet.consumeToken() {
        print("Expired token cannot be consumed")
    }
}
```

## Working with SecureVault

For more secure storage, use the `WalletVault` implementation:

``` swift
class YourSecureClass {
    typealias Wallet = WalletManager<WalletVault<BundleType>>
    var wallet: Wallet!
    let secureVault = WalletVault<BundleType>()

    init() {
        wallet = WalletManager(storage: secureVault)
        // Additional secure setup...
    }
}
```

Implementing SwiftWallet in your iOS application provides a robust and
secure way to manage virtual tokens, with flexible storage options and
comprehensive testing to ensure reliability.
