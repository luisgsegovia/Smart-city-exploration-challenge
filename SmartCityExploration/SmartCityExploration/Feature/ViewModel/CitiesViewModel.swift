//
//  CitiesViewModel.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import Combine

final class CitiesViewModel: ObservableObject {
    private let apiClient: CitiesAPIClientProtocol
    private let persistentStore: CitiesPersistentStore
    private let searchHelper: SearchHelperProtocol

    init(apiClient: CitiesAPIClientProtocol, persistentStore: CitiesPersistentStore, searchHelper: SearchHelperProtocol) {
        self.apiClient = apiClient
        self.persistentStore = persistentStore
        self.searchHelper = searchHelper
    }

    enum UIState: Equatable {
        case loading
        case idle(items: [CityItem])
        case error
    }

    @Published var state: UIState = .loading

    @Published var searchText: String = "" {
        didSet {
            guard !searchText.isEmpty else { return }
            performSearch(of: searchText)
        }
    }

    func performSearch(of text: String) {
        let filteredItems = searchHelper.search(text: text)
        state = .idle(items: filteredItems.sorted(by: { $0.name < $1.name }))
    }

    func toggleFavorite(item: CityItem, isFavorite: Bool) {
        Task {
            isFavorite ?
            await persistentStore.addAsFavorite(item) :
            await persistentStore.removeAsFavorite(item)
        }
    }

    /// This function is only executed once
    func retrieveCities() {
        Task {
            let result = await persistentStore.retrieve()

            switch result {
            case .success(let items) where items == .none:
                await performRemoteRetrieveAndSave()
            case .success(let items):
                guard let items else {
                    state = .error
                    return
                }
                await set(state: .idle(items: items.sorted(by: { $0.name < $1.name })))
                searchHelper.initiate(with: items)
            case .failure:
                await set(state: .error)

            }
        }
    }

    private func performRemoteRetrieveAndSave() async {
        guard let remoteItems = await retrieveFromNetwork() else {
            state = .error
            return
        }

        do {
            try await insertToStore(items: remoteItems.map { $0.toLocal })
        } catch {
            state = .error
        }

        let cities = await retrieveFromStore()

        await set(state:.idle(items: cities))
        searchHelper.initiate(with: cities)
    }

    private func retrieveFromNetwork() async -> [RemoteCityItem]? {
        let result = await apiClient.retrieveCities()
        switch result {
        case .success(let cities):
            return cities
        case .failure:
            state = .error
            return nil
        }
    }

    private func insertToStore(items: [CityItem]) async throws {
        let result = await persistentStore.insert(items: items, timestamp: .now)
        switch result {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }

    private func retrieveFromStore() async -> [CityItem] {
        let result = await persistentStore.retrieve()
        switch result {
        case .success(let items):
            guard let items else { return [] }
            return items
        case .failure:
            return []
        }
    }

    @MainActor
    private func set(state: UIState) {
        self.state = state
    }
}
