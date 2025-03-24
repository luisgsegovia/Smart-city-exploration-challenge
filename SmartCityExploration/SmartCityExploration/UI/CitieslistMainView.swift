//
//  CitieslistMainView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import SwiftUI

struct CitieslistMainView: View {
    @State private var isFirstTime: Bool = true
    @ObservedObject private var viewModel: CitiesViewModel = FeatureComposer.compose()

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                Text("Loading...")
            case let .idle(items):
                NavigationStack {
                    ScrollView {
                        LazyVStack {
                            ForEach (items) { item in
                                NavigationLink(value: item) {
                                    CityListItemView(name: item.name, country: item.country, isFavorite: item.isFavorite, toggleAction: { viewModel.toggleFavorite(item: item, isFavorite: $0) })
                                }
                            }
                        }
                        .padding([.horizontal], 16)
                    }
                    .navigationDestination(for: CityItem.self) { item in MapLocationView(latitude: item.latitude, longitude: item.longitude)
                            .navigationTitle("\(item.name), \(item.country)")
                    }
                }
                .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer)
            case .error:
                EmptyView()
            }
        }
        .onAppear {
            if isFirstTime {
                viewModel.retrieveCities()
                isFirstTime = false
            }
        }
    }
}

#Preview {
    CitieslistMainView()
}
