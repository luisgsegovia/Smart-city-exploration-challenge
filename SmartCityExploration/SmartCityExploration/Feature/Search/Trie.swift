//
//  Trie.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

final class TrieNode {
    var children: [Character: TrieNode] = [:]
    var items: [CityItem] = []
}

final class Trie {
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
