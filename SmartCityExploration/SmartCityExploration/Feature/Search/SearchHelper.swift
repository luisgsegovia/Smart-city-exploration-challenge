//
//  SearchHelper.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

final class SearchHelper: SearchHelperProtocol {
    private let trie = Trie()

    func initiate(with items: [CityItem]) {
        items.forEach { trie.insert($0) }
    }
    
    func search(text: String) -> [CityItem] {
        return trie.searchPrefix(text)
    }
}
