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

struct CityResponseDTO: Codable, Equatable {
    let country, name: String
    let id: Int
    let coord: Coord

    enum CodingKeys: String, CodingKey {
        case country, name
        case id = "_id"
        case coord
    }

    struct Coord: Codable, Equatable {
        let lon, lat: Double
    }
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
        let result = await httpClient.get(from: url)
        switch result {
        case let .success((data, response)):
            guard response.statusCode == 200 else { return .failure(.networkError) }
            do {
                return .success(try mapDataToCities(data))
            } catch {
                return .failure(.decodingError)
            }
        case .failure:
            return .failure(.networkError)
        }
    }

    private func mapDataToCities(_ data: Data) throws -> [CityResponseDTO] {
        let decoder = JSONDecoder()
        guard let dataObjects = try? decoder.decode([CityResponseDTO].self, from: data) else { throw ServiceError.decodingError }
        return dataObjects
    }
}

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
