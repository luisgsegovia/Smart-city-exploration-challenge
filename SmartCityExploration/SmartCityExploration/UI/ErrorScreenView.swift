//
//  ErrorScreenView.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 24/03/25.
//

import SwiftUI

struct ErrorScreenView: View {
    private var retryAction: () -> Void

    public init(retryAction: @escaping () -> Void) {
        self.retryAction = retryAction
    }

    var body: some View {
        VStack {
            Group {
                Text("☹️")
                Text("Sorry, an error has ocurred")
            }
            .font(.largeTitle)

            Button("Retry") { retryAction() }
            .padding(8)
            .font(.largeTitle)
        }
    }
}

#Preview {
    ErrorScreenView(retryAction: {})
}
