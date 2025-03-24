//
//  CityListItemView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import SwiftUI

struct CityListItemView: View {
    private let name: String
    private let country: String
    @State private var isFavorite: Bool

    private var toggleAction: ((Bool) -> Void)?

    public init(name: String, country: String, isFavorite: Bool, toggleAction: ((Bool) -> Void)? = nil) {
        self.name = name
        self.country = country
        self.isFavorite = isFavorite
        self.toggleAction = toggleAction
    }

    var body: some View {
        HStack {
            Text("\(name), \(country)")
            Spacer()
            Button {
                isFavorite.toggle()
                toggleAction?(isFavorite)
            } label: {
                Image(systemName: isFavorite ? "star.fill" : "star")
            }
        }
    }
}
