//
//  HTTPClient.swift
//  SmartCityExploration
//
//  Created by Luis Segovia on 23/03/25.
//

import Foundation

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

    func get(from url: URL) async -> Result
}

final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession) {
        self.session = session
    }

    private struct UnexpectedValuesRepresentation: Error {}

    public func get(from url: URL) async -> HTTPClient.Result {
        do {
            let (data, response) = try await session.data(from: url)
            if let response = response as? HTTPURLResponse {
                return .success((data, response))
            } else {
                throw UnexpectedValuesRepresentation()
            }
        } catch {
            return .failure(NSError(domain: "", code: 0))
        }
    }
}
