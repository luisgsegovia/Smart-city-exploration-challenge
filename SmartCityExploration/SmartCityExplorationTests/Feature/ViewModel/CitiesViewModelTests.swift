//
//  CitiesViewModelTests.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration
import XCTest
import Combine

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

