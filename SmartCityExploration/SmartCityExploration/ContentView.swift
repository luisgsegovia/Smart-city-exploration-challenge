//
//  ContentView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var viewModel: CitiesViewModel = FeatureComposer.compose()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
