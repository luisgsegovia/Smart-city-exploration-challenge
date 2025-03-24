//
//  CitiesPersistentStore.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import Foundation

protocol CitiesPersistentStore {
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrievalResult = Result<[CityItem]?, Error>
    typealias RetrievalCompletion = (RetrievalResult) -> Void

    func retrieve() async -> RetrievalResult
    func insert(items: [CityItem], timestamp: Date) async -> InsertionResult
    func addAsFavorite(_ item: CityItem) async
    func removeAsFavorite(_ item: CityItem) async
}
