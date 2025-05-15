//
//  DesignSystemProtocol.swift
//  BuyBuy
//
//  Created by MDW on 15/05/2025.
//

import SwiftUI

protocol DesignSystemProtocol {
    var colors: AppColor.Type { get }
    var fonts: AppFont.Type { get }
    var spacing: Spacing.Type { get }
    var theme: Theme.Type { get }
}
