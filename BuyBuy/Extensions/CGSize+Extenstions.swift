//
//  CGSize+Extenstions.swift
//  BuyBuy
//
//  Created by MDW on 28/06/2025.
//

import Foundation

extension CGSize {
    var isLandscape: Bool {
        width > height
    }
    
    var isPortrait: Bool {
        height >= width
    }
    
    var shorterSide: CGFloat {
        min(width, height)
    }
    
    var longerSide: CGFloat {
        max(width, height)
    }
}
