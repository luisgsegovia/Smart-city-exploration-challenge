//
//  FeatureComposer.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import CoreData

enum FeatureComposer {
    static func compose() -> CitiesViewModel {
        let url = URL(string: "https://gist.github.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json")!
        let session = URLSession(configuration: .default)
        let httpClient = URLSessionHTTPClient(session: session)
        let apiClient = CitiesAPIClient(httpClient: httpClient, url: url)

        let persistentStoreURL = NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("cities-store.sqlite")
        let persistentStore = try! CoreDataStore(storeURL: persistentStoreURL)

        let searchHelper = SearchHelper()

        let viewModel = CitiesViewModel(apiClient: apiClient, persistentStore: persistentStore, searchHelper: searchHelper)

        return viewModel
    }
}
