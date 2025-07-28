//
//  Request.swift
//  NetworkLayer
//
//  Created by Mehmet Ali ÇELEBİ on 28.07.2025.
//

import Foundation

public protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
    var body: Data? { get }
}

public extension APIEndpoint {
    var headers: [String: String] { [:] }
    var queryParameters: [String: String] { [:] }
    var body: Data? { nil }
}
