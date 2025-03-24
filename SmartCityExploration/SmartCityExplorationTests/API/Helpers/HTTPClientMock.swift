//
//  HTTPClientMock.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import Foundation

final class HTTPClientMock: HTTPClient {
    var clientResponse: HTTPClient.Result!

    func get(from url: URL) async -> HTTPClient.Result {
        guard let clientResponse else {
            fatalError("Developer error, mock response not set.")
        }

        return clientResponse
    }
}
