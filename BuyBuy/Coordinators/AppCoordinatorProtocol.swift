//
//  AppCoordinatorProtocol.swift
//  BuyBuy
//
//  Created by MDW on 14/05/2025.
//

import Foundation
import Combine

protocol AppCoordinatorProtocol: ObservableObject {
    var needRefreshListsPublisher: AnyPublisher<Bool, Never> { get }
    var needRefreshLists: Bool { get }
    
    func setNeedRefreshLists(_ state: Bool)
    func openList(_ id: UUID)
    func openListSettings(_ list: ShoppingList, isNew: Bool)
    func openAbout()
    func openSettings()
    func back()
}
