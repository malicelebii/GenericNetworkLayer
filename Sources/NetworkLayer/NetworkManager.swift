// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

public struct NetworkManager {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint, decoder: JSONDecoder = JSONDecoder()) async throws -> T {
        let urlRequest = try URLRequestBuilder(endpoint: endpoint).build()
        
        let (data, response) = try await session.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, response: data)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
