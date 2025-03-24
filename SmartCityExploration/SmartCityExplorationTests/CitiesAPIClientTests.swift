//
//  CitiesAPIClientTests.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import XCTest
@testable import SmartCityExploration

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL) async -> Result
}

struct CityResponseDTO: Equatable {

}

final class CitiesAPIClient {
    typealias Result = Swift.Result<[CityResponseDTO], ServiceError>

    enum ServiceError: Error, Equatable {
        case networkError
        case decodingError
    }

    private let httpClient: HTTPClient
    private var url: URL

    init(httpClient: HTTPClient, url: URL) {
        self.httpClient = httpClient
        self.url = url
    }

    func retrieveCities() async -> Result {
        return .success([])
    }
}

final class CitiesAPIClientTests: XCTestCase {
    func test_retrieveCities_returnsEmptyItems() async {
        let httpClient = HTTPClientMock()
        let sut = CitiesAPIClient(httpClient: httpClient, url: anyURL())

        let result = await sut.retrieveCities()

        XCTAssertEqual(result, .success([]))
    }

    private func anyURL() -> URL {
        URL(string: "https://www.apple.com")!
    }
}

private final class HTTPClientMock: HTTPClient {
    var clientResponse: HTTPClient.Result!

    func get(from url: URL) async -> HTTPClient.Result {
        guard let clientResponse else {
            fatalError("Developer error, mock response not set.")
        }

        return clientResponse
    }
}
