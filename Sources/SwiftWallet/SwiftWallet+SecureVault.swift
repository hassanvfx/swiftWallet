//
//  WalletManager+SecureVault.swift
//  TwinChatAI
//
//  Created by Eon Fluxor on 1/5/24.
//

import SecureVault
import SwiftUI

public class WalletVault<BUNDLE: WalletBundle>: WalletStorage {
    let purchasedKey = "purchasedKey"
    let consumedKey = "consumedKey"
    private(set) var vault: SecureVault!
    private(set) var onLoadedState: (() -> Void)?
    public init(namespace: String = "wallet", onLoadedState: (() -> Void)? = nil) {
        vault = SecureVault(namespace: namespace)
        self.onLoadedState = onLoadedState
        loadState()
    }

    public func loadState() {
        Task(priority: .background) {
            let purchasedString = await self.vault.get(key: self.purchasedKey) ?? ""
            let consumedString = await self.vault.get(key: self.consumedKey) ?? ""
            purchased = Codec.object(fromJSON: purchasedString) ?? []
            consumed = Codec.object(fromJSON: consumedString) ?? []
            DispatchQueue.main.async {
                self.onLoadedState?()
            }
        }
    }

    public func reset() {
        purchased = []
        consumed = []
    }

    public var purchased = [WalletToken<BUNDLE>]() {
        didSet {
            guard let purchasedString = try? purchased.asJSONString() else { return }
            Task(priority: .background) {
                await self.vault.set(key: self.purchasedKey, value: purchasedString)
            }
        }
    }

    public var consumed = [WalletToken<BUNDLE>]() {
        didSet {
            guard let consumedString = try? consumed.asJSONString() else { return }
            Task(priority: .background) {
                await self.vault.set(key: self.consumedKey, value: consumedString)
            }
        }
    }
}
