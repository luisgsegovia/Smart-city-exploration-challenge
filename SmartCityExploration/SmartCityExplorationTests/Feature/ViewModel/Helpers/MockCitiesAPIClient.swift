//
//  MockCitiesAPIClient.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration

final class MockCitiesAPIClient: CitiesAPIClientProtocol {
    var result: CitiesAPIClientProtocol.Result!
    func retrieveCities() async -> CitiesAPIClientProtocol.Result {
        guard let result else {
            fatalError("Result was not set, develoepr error")
        }
        return result
    }
}
