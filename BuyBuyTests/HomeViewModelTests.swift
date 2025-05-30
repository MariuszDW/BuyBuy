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
    
    @MainActor
    func testAddItem() async {
        let testListID = UUID()
        let testItemID = UUID()
        let testItem = ShoppingItem(id: testItemID, order: 0, listID: testListID, name: "Milk", note: "Pilos 3.2%, 1L", status: .pending)
        
        let mockRepository = TestMockDataManager()

        let addItemExp = expectation(description: "addItemExp")
        mockRepository.addOrUpdateItemHandler = { item in
            XCTAssertEqual(item.id, testItemID)
            XCTAssertEqual(item.listID, testListID)
            XCTAssertEqual(item.name, "Milk")
            XCTAssertEqual(item.note, "Pilos 3.2%, 1L")
            XCTAssertEqual(item.status, .pending)
            XCTAssertEqual(item.order, 0)
            addItemExp.fulfill()
        }
        
        let fetchListExp = expectation(description: "fetchListExp")
        mockRepository.fetchListHandler = { listID in
            XCTAssertEqual(listID, testListID)
            fetchListExp.fulfill()
        }
        
        let viewModel = ShoppingListViewModel(listID: testListID, dataManager: mockRepository, coordinator: TestMockAppCoordinator())
        await viewModel.addOrUpdateItem(testItem)

        await fulfillment(of: [addItemExp, fetchListExp], timeout: 5)
    }
}
