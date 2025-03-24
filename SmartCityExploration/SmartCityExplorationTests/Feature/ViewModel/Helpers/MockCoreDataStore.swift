//
//  MockCoreDataStore.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration
import Foundation

final class MockCoreDataStore: CitiesPersistentStore {
    var retrievalResult: RetrievalResult!
    var insertionResult: InsertionResult!
    var favoritesResult: Bool!

    func retrieve() async -> RetrievalResult {
        guard let retrievalResult else {
            fatalError("Result was not set, developer error")
        }
        return retrievalResult
    }
    
    func insert(items: [SmartCityExploration.CityItem], timestamp: Date) async -> InsertionResult {
        guard let insertionResult else {
            fatalError("Result was not set, developer error")
        }
        return insertionResult
    }
    
    func addAsFavorite(_ item: SmartCityExploration.CityItem) async -> Bool {
        guard let favoritesResult else {
            fatalError("Result was not set, developer error")
        }
        return favoritesResult
    }
    
    func removeAsFavorite(_ item: SmartCityExploration.CityItem) async -> Bool {
        guard let favoritesResult else {
            fatalError("Result was not set, developer error")
        }
        return favoritesResult
    }
}
