//
//  CitiesAPIClientTests.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import XCTest
@testable import SmartCityExploration

final class CitiesAPIClientTests: XCTestCase {
    func test_retrieveCities_returnsEmptyItems() async {
        let (httpClient, sut) = makeSUT()
        httpClient.clientResponse = .success((createValidEmptyJSON(), .init()))

        let result = await sut.retrieveCities()

        XCTAssertEqual(result, .success([]))
    }

    func test_retrieveCities_whenNetworkErrorOccurs_returnsNetworkError() async {
        let (httpClient, sut) = makeSUT()
        httpClient.clientResponse = .failure(NSError(domain: "", code: 0, userInfo: nil))

        let result = await sut.retrieveCities()

        XCTAssertEqual(result, .failure(.networkError))
    }

    func test_retrieveCities_whenDecodingErrorOccurs_returnsDecodingError() async {
        let (httpClient, sut) = makeSUT()
        httpClient.clientResponse = .success((createInvalidJSONData(), .init()))

        let result = await sut.retrieveCities()

        XCTAssertEqual(result, .failure(.decodingError))
    }

    func test_retrieveCities_returnsDecodedItems() async {
        let (httpClient, sut) = makeSUT()
        httpClient.clientResponse = .success((createValidJSONData(), .init()))
        let expectedDecodedItem = RemoteCityItem(country: "MX", name: "Mexico City", id: 1234, coord: .init(lon: -10.00, lat: 10.00))

        let result = await sut.retrieveCities()

        XCTAssertEqual(result, .success([expectedDecodedItem]))
    }

    private func makeSUT() -> (httpClient: HTTPClientMock, sut: CitiesAPIClient) {
        let httpClientMock = HTTPClientMock()
        let sut = CitiesAPIClient(httpClient: httpClientMock, url: anyURL())

        return (httpClientMock, sut)
    }

    private func anyURL() -> URL {
        URL(string: "https://www.apple.com")!
    }

    private func createValidEmptyJSON() -> Data {
        return Data("[]".utf8)
    }

    private func createInvalidJSONData() -> Data {
        let invalidJSONData = ""
        return Data(invalidJSONData.utf8)
    }

    private func createValidJSONData() -> Data {
        let jsonData: String = "[{\"country\":\"MX\",\"name\":\"Mexico City\",\"_id\":1234,\"coord\":{\"lon\":-10.00,\"lat\":10.00}}]"
        return Data(jsonData.utf8)
    }

}
