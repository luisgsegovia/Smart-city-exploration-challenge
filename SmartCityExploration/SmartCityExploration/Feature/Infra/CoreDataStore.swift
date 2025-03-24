//
//  CoreDataStore.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import CoreData

final class CoreDataStore {
    private static let modelName = "City"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataStore.self))

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataStore.model else {
            throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(name: CoreDataStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }

}

extension CoreDataStore: CitiesPersistentStore {
    func retrieve() async -> RetrievalResult {
        let context = self.context
        return await withCheckedContinuation { continuation in
            context.perform {
                let result = Result {
                    try ManagedCache.find(in: context)?.localCities
                }
                continuation.resume(returning: result)
            }
        }
    }

    func insert(items: [CityItem], timestamp: Date) async -> InsertionResult {
        let context = self.context
        return await withCheckedContinuation { continuation in
            context.perform {
                let result = Result {
                    let managedCache = try ManagedCache.newUniqueInstance(in: context)
                    managedCache.timestamp = timestamp
                    managedCache.cities = ManagedCityItem.cities(from: items, in: context)
                    try context.save()
                }
                continuation.resume(returning: result)
            }
        }
    }

    func addAsFavorite(_ item: CityItem) async {
        // Not implemented yet
    }

    func removeAsFavorite(_ item: CityItem) async {
        // Not implemented yet
    }
}

private extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw $0 }

        return container
    }
}

private extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}

