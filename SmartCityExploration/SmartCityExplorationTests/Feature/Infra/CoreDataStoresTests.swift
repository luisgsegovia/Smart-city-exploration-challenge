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

    func test_addAsFavorite_updatesItemFavoriteStatusAsTrue() async {
        let sut = makeSUT()

        let insertionResult = await sut.insert(items: [generateUniqueItem()], timestamp: .init())

        XCTAssertNotNil(try? insertionResult.get())

        let itemToAddAsFavorite = CityItem(country: "", name: "", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: true)
        let result = await sut.addAsFavorite(itemToAddAsFavorite)
        XCTAssertTrue(result)

        let retrievalResult = await sut.retrieve()
        guard let retrievedItem = try? retrievalResult.get()?.first else {
            XCTFail("Expected item to be retrieved")
            return
        }

        XCTAssertTrue(retrievedItem.isFavorite)
    }

    func test_removeAsFavorite_updatesItemFavoriteStatusAsFalse() async {
        let sut = makeSUT()

        let itemToAdd = CityItem(country: "", name: "", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: true)
        let insertionResult = await sut.insert(items: [itemToAdd], timestamp: .init())

        XCTAssertNotNil(try? insertionResult.get())

        let itemToUpdate = generateUniqueItem()
        let result = await sut.removeAsFavorite(itemToUpdate)
        XCTAssertTrue(result)

        let retrievalResult = await sut.retrieve()
        guard let retrievedItem = try? retrievalResult.get()?.first else {
            XCTFail("Expected item to be retrieved")
            return
        }

        XCTAssertFalse(retrievedItem.isFavorite)
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
