//
//  Models.swift
//  TwinChatAITests
//
//  Created by Eon Fluxor on 1/5/24.
//

import Foundation
import SwiftWallet

enum BundleType: WalletBundle {
    case day
    case week
    case month
    case year
    var tokens:Int{
        switch self{
        case .day:
            return 10
        case .week:
            return 100
        case .month:
            return 500
        case .year:
            return 1000
        }
    }
    var expiration:Date{
        switch self {
        case .day:
            return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            
        case .week:
            return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        case .month:
            return Calendar.current.date(byAdding: .month, value: 1, to: Date())!
        case .year:
            return Calendar.current.date(byAdding: .year, value: 1, to: Date())!
            
        }
    }
}
