//
//  HapticEngineProtocol.swift
//  BuyBuy
//
//  Created by MDW on 08/07/2025.
//

import Foundation
import UIKit

enum HapticType {
    case impact(style: UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(type: UINotificationFeedbackGenerator.FeedbackType)
    case selection
}

@MainActor
protocol HapticEngineProtocol {
    func play(_ type: HapticType)
    
    func playItemChecked()
    func playItemDeleted()
    func playSuccess()
    func playError()
    func playSelectionChanged()
}
