//
//  SearchHelperProtocol.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

protocol SearchHelperProtocol {
    func initiate(with items: [CityItem])
    func search(text: String) -> [CityItem]
}
