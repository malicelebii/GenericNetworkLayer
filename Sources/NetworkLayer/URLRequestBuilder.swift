//
//  URLRequestBuilder.swift
//  NetworkLayer
//
//  Created by Mehmet Ali ÇELEBİ on 28.07.2025.
//

import Foundation

internal struct URLRequestBuilder {
    private let endpoint: APIEndpoint
    
    internal init(endpoint: APIEndpoint) {
        self.endpoint = endpoint
    }
    
    internal func build() throws -> URLRequest {
        guard var components = URLComponents(url: endpoint.baseURL.appendingPathComponent(endpoint.path), resolvingAgainstBaseURL: true) else {
            throw NetworkError.invalidURL("Invalid base URL or path.")
        }
        
        if !endpoint.queryParameters.isEmpty {
            components.queryItems = endpoint.queryParameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        
        guard let url = components.url else {
            throw NetworkError.invalidURL("Failed to construct URL from components.")
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers
        
        if let body = endpoint.body {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
}
