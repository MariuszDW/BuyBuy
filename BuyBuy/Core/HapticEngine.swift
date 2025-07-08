//
//  HapticEngine.swift
//  BuyBuy
//
//  Created by MDW on 08/07/2025.
//

import Foundation
import UIKit

@MainActor
final class HapticEngine: HapticEngineProtocol {
    private lazy var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    
    private lazy var notificationGenerator: UINotificationFeedbackGenerator = {
        let generator = UINotificationFeedbackGenerator()
        return generator
    }()
    
    private lazy var selectionGenerator: UISelectionFeedbackGenerator = {
        let generator = UISelectionFeedbackGenerator()
        return generator
    }()
    
    func play(_ type: HapticType) {
        switch type {
        case .impact(let style):
            let generator = impactGenerator(for: style)
            generator.prepare()
            generator.impactOccurred()
            
        case .notification(let notificationType):
            notificationGenerator.prepare()
            notificationGenerator.notificationOccurred(notificationType)
            
        case .selection:
            selectionGenerator.prepare()
            selectionGenerator.selectionChanged()
        }
    }
    
    // MARK: - Generator cache
    
    private func impactGenerator(for style: UIImpactFeedbackGenerator.FeedbackStyle) -> UIImpactFeedbackGenerator {
        if let generator = impactGenerators[style] {
            return generator
        } else {
            let newGenerator = UIImpactFeedbackGenerator(style: style)
            impactGenerators[style] = newGenerator
            return newGenerator
        }
    }
    
    // MARK: - Convenience methods
    
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
