//
//  CitiesAPIClient.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import Foundation

final class CitiesAPIClient {
    typealias Result = Swift.Result<[RemoteCityItem], ServiceError>

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

    private func mapDataToCities(_ data: Data) throws -> [RemoteCityItem] {
        let decoder = JSONDecoder()
        guard let dataObjects = try? decoder.decode([RemoteCityItem].self, from: data) else { throw ServiceError.decodingError }
        return dataObjects
    }
}
