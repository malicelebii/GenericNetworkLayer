//
//  NetworkError.swift
//  NetworkLayer
//
//  Created by Mehmet Ali ÇELEBİ on 28.07.2025.
//

import Foundation

public enum NetworkError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case serverError(statusCode: Int, response: Data?)
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let message):
            return "Invalid URL: \(message)"
        case .invalidResponse:
            return "The server returned an invalid response."
        case .serverError(let statusCode, _):
            return "The server returned a status code of \(statusCode)."
        case .decodingError(let error):
            return "Failed to decode the response: \(error.localizedDescription)"
        }
    }
}
