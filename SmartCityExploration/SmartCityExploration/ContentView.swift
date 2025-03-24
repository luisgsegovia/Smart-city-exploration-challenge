//
//  ContentView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import SwiftUI

struct ContentView: View {
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
                                Text("\(item.name), \(item.country)")
                            }
                        }

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
    ContentView()
}
