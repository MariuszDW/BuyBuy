//
//  AppCoordinatorTests.swift
//  BuyBuyTests
//
//  Created by MDW on 14/05/2025.
//

import XCTest
@testable import BuyBuy

final class HomeViewModelTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testCreateListTapped_CallsCoordinator() {
        let mockCoordinator = MockAppCoordinator()
        let viewModel = HomeViewModel(coordinator: mockCoordinator)
        
        viewModel.createListTapped()
        
        XCTAssertTrue(mockCoordinator.goToShoppingListCalled)
    }
}
