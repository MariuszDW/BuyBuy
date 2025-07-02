//
//  OrientedContainerView.swift
//  BuyBuy
//
//  Created by MDW on 01/07/2025.
//

import SwiftUI

struct OrientedContainerView<Content1: View, Content2: View>: View {
    let isLandscape: Bool
    let view1: Content1
    let view2: Content2
    let minSpace: CGFloat = 32
    
    var body: some View {
        Group {
            if isLandscape {
                HStack {
                    Spacer()
                    view1
                    Spacer(minLength: minSpace)
                    view2
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    view1
                    Spacer(minLength: minSpace)
                    view2
                    Spacer()
                }
            }
        }
    }
}
