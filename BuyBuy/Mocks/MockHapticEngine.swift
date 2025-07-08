//
//  MockHapticEngine.swift
//  BuyBuy
//
//  Created by MDW on 08/07/2025.
//

import Foundation

@MainActor
final class MockHapticEngine: HapticEngineProtocol {
    var isEnabled: Bool = true
    
    func play(_ type: HapticType) {}
    
    func playItemChecked() {
        play(.impact(style: .medium))
    }
    
    func playItemDeleted() {
        play(.impact(style: .heavy))
    }
    
    func playSuccess() {
        play(.notification(type: .success))
    }
    
    func playError() {
        play(.notification(type: .error))
    }
    
    func playSelectionChanged() {
        play(.selection)
    }
}
