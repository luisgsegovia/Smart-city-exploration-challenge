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
    func search(text: String)
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

final class MockCitiesAPIClient: CitiesAPIClientProtocol {
    var result: CitiesAPIClientProtocol.Result!
    func retrieveCities() async -> CitiesAPIClientProtocol.Result {
        guard let result else {
            fatalError("Result was not set, develoepr error")
        }
        return result
    }
}

final class MockSearchHelper: SearchHelperProtocol {
    func initiate(with items: [SmartCityExploration.CityItem]) {
        //
    }
    
    func search(text: String) {
        //
    }

}
