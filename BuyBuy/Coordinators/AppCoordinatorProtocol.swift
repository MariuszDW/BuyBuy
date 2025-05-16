//
//  AppCoordinatorProtocol.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation

protocol AppCoordinatorProtocol: AnyObject {
    func goToShoppingListDetails(_ id: UUID)
    func goToSettings()
    func back()
}
