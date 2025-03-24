//
//  RemoteCityItem.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

struct RemoteCityItem: Codable, Equatable {
    let country, name: String
    let id: Int
    let coord: Coord

    enum CodingKeys: String, CodingKey {
        case country, name
        case id = "_id"
        case coord
    }

    struct Coord: Codable, Equatable {
        let lon, lat: Double
    }
}

extension RemoteCityItem {
    var toLocal: CityItem {
        .init(country: country, name: name, id: id, latitude: coord.lat, longitude: coord.lon, isFavorite: false)
    }
}
