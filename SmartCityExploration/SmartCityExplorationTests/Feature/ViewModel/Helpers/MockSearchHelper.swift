//
//  MockSearchHelper.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

@testable import SmartCityExploration

final class MockSearchHelper: SearchHelperProtocol {
    var items: [CityItem] = []
    func initiate(with items: [SmartCityExploration.CityItem]) {
        // No implementation needed
    }
    
    func search(text: String) -> [CityItem] {
        return items
    }

}
