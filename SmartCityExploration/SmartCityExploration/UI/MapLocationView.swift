//
//  MapLocationView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import MapKit
import SwiftUI

struct MapLocationView: View {
    let latitude: Double
    let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    var body: some View {
        ZStack {
            Map(initialPosition: generateCameraPosition()) {
                Marker("Location", coordinate: .init(latitude: latitude, longitude: longitude))
            }
        }
    }

    private func generateCameraPosition() -> MapCameraPosition {
        .region(.init(center: .init(latitude: latitude, longitude: longitude), latitudinalMeters: 1200, longitudinalMeters: 1200))
    }
}
