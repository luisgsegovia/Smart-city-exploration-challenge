//
//  CoreDataStoresTests.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration
import XCTest

final class CoreDataStoresTests: XCTestCase {
    func test_retrieve_deliversEmptyCacheItems() async {
        let sut = makeSUT()

        let result = await sut.retrieve()

        XCTAssertEqual(try? result.get(), .none)
    }

    func test_retrieve_deliversCachedItemsOnNonEmptyCache() async {
        let sut = makeSUT()

        let insertionResult = await sut.insert(items: [generateUniqueItem(), generateUniqueItem()], timestamp: .init())

        XCTAssertNotNil(try? insertionResult.get())

        let retrieveResult = await sut.retrieve()
        guard let items = try? retrieveResult.get() else {
            XCTFail("Items are nil, expected non nil items")
            return
        }

        XCTAssertEqual(items.count, 2)
    }

    private func makeSUT() -> CitiesPersistentStore {
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataStore(storeURL: storeURL)
        return sut
    }

    private func generateUniqueItem() -> CityItem {
        .init(country: "MEX", name: "CDMX", id: 1234, latitude: 10.00, longitude: 10.00, isFavorite: false)
    }
}
