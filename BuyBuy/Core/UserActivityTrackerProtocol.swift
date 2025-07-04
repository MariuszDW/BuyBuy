//
//  UserActivityTrackerProtocol.swift
//  BuyBuy
//
//  Created by MDW on 04/07/2025.
//

import Foundation

@MainActor
protocol UserActivityTrackerProtocol: AnyObject {
    var installationDate: Date { get }
    var lastTipDate: Date? { get }
    func tipCount(for tipID: String) -> Int
    var totalTipsCount: Int { get }
    func incrementTipCount(for tipID: String)
    var lastTipJarShownDate: Date { set get }
}
