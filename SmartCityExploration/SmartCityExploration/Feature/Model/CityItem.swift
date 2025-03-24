//
//  CityItem.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

struct CityItem {
    let country, name: String
    let id: Int
    let latitude, longitude: Double
    let isFavorite: Bool
}

extension CityItem: Equatable {}
extension CityItem: Identifiable {}
extension CityItem: Hashable {}
