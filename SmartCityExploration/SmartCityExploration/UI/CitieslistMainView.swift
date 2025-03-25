//
//  CitieslistMainView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import SwiftUI

struct CitieslistMainView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    @State private var isFirstTime: Bool = true
    @ObservedObject private var viewModel: CitiesViewModel = FeatureComposer.compose()

    var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading, please wait...")
                    .scaleEffect(2.0, anchor: .center)
            case let .idle(items):
                if verticalSizeClass == .regular && verticalSizeClass == .compact {
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
                        .navigationTitle("Smart City Exploration")
                        .navigationDestination(for: CityItem.self) { item in MapLocationView(latitude: item.latitude, longitude: item.longitude)
                                .navigationTitle("\(item.name), \(item.country)")
                        }
                    }
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer)
                } else {
                    NavigationSplitView(sidebar: {
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
                        .navigationTitle("Smart City Exploration")
                        .navigationDestination(for: CityItem.self) { item in MapLocationView(latitude: item.latitude, longitude: item.longitude)
                                .navigationTitle("\(item.name), \(item.country)")
                        }
                    }, detail: {
                        Text("<- Please select a city from the sidebar")
                    })
                    .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer)
                }
            case .error:
                ErrorScreenView(retryAction: {  })
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
