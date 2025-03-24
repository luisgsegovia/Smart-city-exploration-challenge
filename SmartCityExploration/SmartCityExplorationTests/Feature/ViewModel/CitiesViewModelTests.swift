//
//  CitiesViewModelTests.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration
import XCTest
import Combine

protocol SearchHelperProtocol {
    func initiate(with items: [CityItem])
    func search(text: String) -> [CityItem]
}

final class SearchHelper: SearchHelperProtocol {
    private let trie = Trie()

    func initiate(with items: [CityItem]) {
        items.forEach { trie.insert($0) }
    }
    
    func search(text: String) -> [CityItem] {
        return trie.searchPrefix(text)
    }
}

class TrieNode {
    var children: [Character: TrieNode] = [:]
    var items: [CityItem] = []
}

class Trie {
    private let root = TrieNode()

    // Insert an item into the Trie
    func insert(_ item: CityItem) {
        var node = root
        for char in item.name.lowercased() {
            if node.children[char] == nil {
                node.children[char] = TrieNode()
            }
            node = node.children[char]!
        }
        node.items.append(item) // Store the item at the end node
    }

    // Search for all items with a given prefix
    func searchPrefix(_ prefix: String) -> [CityItem] {
        var node = root
        var result: [CityItem] = []
        let prefix = prefix.lowercased()

        // Traverse to the node representing the prefix
        for char in prefix {
            guard let child = node.children[char] else { return result }
            node = child
        }

        // Perform DFS to find all items with the given prefix
        dfs(node, &result)
        return result
    }

    private func dfs(_ node: TrieNode, _ result: inout [CityItem]) {
        // Add all items at the current node
        result.append(contentsOf: node.items)
        // Traverse all children
        for (_, child) in node.children {
            dfs(child, &result)
        }
    }
}


final class CitiesViewModel {
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

    func performSearch(of text: String) {
        let filteredItems = searchHelper.search(text: text)
        state = .idle(items: filteredItems.sorted(by: { $0.name < $1.name }))
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
                state = .idle(items: items.sorted(by: { $0.name < $1.name }))
                searchHelper.initiate(with: items)
            case .failure:
                state = .error

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

        state = .idle(items: cities)
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

}

private extension RemoteCityItem {
    var toLocal: CityItem {
        .init(country: country, name: name, id: id, latitude: coord.lat, longitude: coord.lon, isFavorite: false)
    }
}

final class CitiesViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    func test_retrieve_executesRemoteRetrievalAndSaves_stateIsIdle() {
        let (mockStore, mockAPIClient, _, sut) = makeSUT()
        let exp = expectation(description: "Wait for state")

        let remoteItem = RemoteCityItem(country: "MEX", name: "CDMX", id: 1234, coord: .init(lon: 0.0, lat: 0.0))
        mockAPIClient.result = .success([remoteItem])

        mockStore.retrievalResult = .success(.none)
        mockStore.insertionResult = .success(())

        match(uiStates: [.loading, .idle(items: [])], in: sut) {
            exp.fulfill()
        }

        sut.retrieveCities()

        wait(for: [exp], timeout: 1)
    }

    func test_retrieve_executesLocalRetrievalOnly_stateIsIdle() {
        let (mockStore, _, _, sut) = makeSUT()
        let exp = expectation(description: "Wait for state")

        let item = CityItem(country: "MEX", name: "CDMX", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: false)

        mockStore.retrievalResult = .success([item])

        match(uiStates: [.loading, .idle(items: [item])], in: sut) {
            exp.fulfill()
        }

        sut.retrieveCities()

        wait(for: [exp], timeout: 1)
    }

    func test_retrieve_executesRetrievalAndFails_stateIsError() {
        let (mockStore, _, _, sut) = makeSUT()
        let exp = expectation(description: "Wait for state")

        mockStore.retrievalResult = .failure(NSError(domain: "Retrieval error", code: 1))

        match(uiStates: [.loading, .error], in: sut) {
            exp.fulfill()
        }

        sut.retrieveCities()

        wait(for: [exp], timeout: 1)
    }

    func test_retrieve_executesRemoteRetrievalAndFails_stateIsError() {
        let (mockStore, mockAPIClient, _, sut) = makeSUT()
        let exp = expectation(description: "Wait for state")

        mockStore.retrievalResult = .success(.none)
        mockAPIClient.result = .failure(.networkError)

        match(uiStates: [.loading, .error], in: sut) {
            exp.fulfill()
        }

        sut.retrieveCities()

        wait(for: [exp], timeout: 1)
    }

    func test_searchText_returnsItems_stateIsIdle() {
        let (mockStore, _, mockSearchHelper, sut) = makeSUT()
        let item =  CityItem(country: "MEX", name: "CDMX", id: 1234, latitude: 0.0, longitude: 0.0, isFavorite: false)
        mockSearchHelper.items = [item]
        let exp = expectation(description: "Wait for state")

        match(uiStates: [.loading, .idle(items: [item])], in: sut) {
            exp.fulfill()
        }

        sut.performSearch(of: "MEX")

        wait(for: [exp], timeout: 1)
    }

    private func makeSUT() -> (store: MockCoreDataStore, apiClient: MockCitiesAPIClient, searchHelper: MockSearchHelper, sut: CitiesViewModel) {
        let mockStore = MockCoreDataStore()
        let mockAPIClient = MockCitiesAPIClient()
        let mockSearchHelper = MockSearchHelper()
        let sut = CitiesViewModel(apiClient: mockAPIClient, persistentStore: mockStore, searchHelper: mockSearchHelper)
        return (mockStore, mockAPIClient, mockSearchHelper, sut)
    }

    private func match(uiStates: [CitiesViewModel.UIState], in sut: CitiesViewModel, finished: @escaping () -> Void) {
        var states = uiStates
        sut.$state
            .sink(receiveValue: { state in
                if let expectedState = states.first {
                    states.remove(at: .zero)
                    XCTAssertEqual(state, expectedState)
                }

                if states.isEmpty {
                    finished()
                }

            })
            .store(in: &cancellables)
    }
}

