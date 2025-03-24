//
//  SearchHelperTests.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration
import XCTest

final class SearchHelperTests: XCTestCase {
    func test_searchForText_returnsItems() {
        let sut = makeSUT()

        sut.initiate(with: generateMultipleItems())

        let results = sut.search(text: "mex")

        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.first!.name, "Mexico City")
    }

    func test_searchForText_returnsEmptyWhenNoMatch() {
        let sut = makeSUT()
        
        sut.initiate(with: generateMultipleItems())
        
        let results = sut.search(text: "invalid")

        XCTAssertTrue(results.isEmpty)
    }

    private func makeSUT() -> SearchHelperProtocol {
        return SearchHelper()
    }

    private func generateMultipleItems() -> [CityItem] {
        return [
            .init(country: "Mexico", name: "Mexico City", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: false),
            .init(country: "Italy", name: "Rome", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: false),
            .init(country: "Germany", name: "Berlin", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: false),
            .init(country: "Hungary", name: "Budapest", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: false),
        ]
    }
}
