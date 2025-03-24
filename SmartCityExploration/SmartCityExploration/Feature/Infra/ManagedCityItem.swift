//
//  ManagedCityItem.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import CoreData

@objc(ManagedCityItem)
final class ManagedCityItem: NSManagedObject {
    @NSManaged var id: Int
    @NSManaged var name: String
    @NSManaged var country: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var isFavorite: Bool
    @NSManaged var cache: ManagedCache
}

extension ManagedCityItem {
    static func cities(from items: [CityItem], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: items.map {
            let managed = ManagedCityItem(context: context)
            managed.id = $0.id
            managed.name = $0.name
            managed.country = $0.country
            managed.latitude = $0.latitude
            managed.longitude = $0.longitude
            managed.isFavorite = $0.isFavorite
            return managed
        })
    }

    var local: CityItem {
        return .init(country: country, name: name, id: id, latitude: latitude, longitude: longitude, isFavorite: isFavorite)
    }
}
