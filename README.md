# GenericNetworkLayer

[![Swift Version](https://img.shields.io/badge/Swift-5.5%2B-orange.svg?style=flat-square)](https://swift.org)
[![iOS Version](https://img.shields.io/badge/iOS-13.0%2B-blue.svg?style=flat-square)](https://developer.apple.com/ios/)
[![Swift Package Manager](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg?style=flat-square)](https://swift.org/package-manager/)

A modern, type-safe, and protocol-oriented networking layer for Swift applications. Built with async/await support and comprehensive error handling.

## Features

- ✅ **Type-Safe**: Protocol-driven approach with compile-time safety
- ✅ **Modern Swift**: Built with async/await and modern Swift concurrency
- ✅ **Generic Design**: Works with any `Decodable` response type
- ✅ **Comprehensive Error Handling**: Detailed error types with meaningful descriptions
- ✅ **Easy Testing**: Mockable interfaces and dependency injection support
- ✅ **Flexible**: Support for all HTTP methods, headers, query parameters, and request body
- ✅ **Lightweight**: Zero external dependencies
- ✅ **Swift Package Manager**: Easy integration with SPM

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Swift 5.5+
- Xcode 13.0+

## Installation

### Swift Package Manager

Add NetworkLayer to your project using Xcode:

1. In Xcode, go to `File` → `Add Package Dependencies`
2. Enter the repository URL: `https://github.com/malicelebii/GenericNetworkLayer.git`
3. Select the version you want to use
4. Click `Add Package`

Or add it to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/malicelebii/GenericNetworkLayer.git", from: "1.0.0")
]
```

## Quick Start

### 1. Define Your API Endpoints

```swift
import NetworkLayer

enum UserAPI {
    case getUser(id: Int)
    case createUser(userData: Data)
    case updateUser(id: Int, userData: Data)
    case deleteUser(id: Int)
}

extension UserAPI: APIEndpoint {
    var baseURL: URL {
        URL(string: "https://api.example.com")!
    }
    
    var path: String {
        switch self {
        case .getUser(let id):
            return "/users/\(id)"
        case .createUser:
            return "/users"
        case .updateUser(let id, _):
            return "/users/\(id)"
        case .deleteUser(let id):
            return "/users/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getUser:
            return .GET
        case .createUser:
            return .POST
        case .updateUser:
            return .PUT
        case .deleteUser:
            return .DELETE
        }
    }
    
    var headers: [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    var body: Data? {
        switch self {
        case .createUser(let userData), .updateUser(_, let userData):
            return userData
        default:
            return nil
        }
    }
}
```

### 2. Define Your Data Models

```swift
struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

struct CreateUserRequest: Codable {
    let name: String
    let email: String
}
```

### 3. Make Network Requests

```swift
class UserService {
    private let networkManager = NetworkManager()
    
    func fetchUser(id: Int) async throws -> User {
        return try await networkManager.request(UserAPI.getUser(id: id))
    }
    
    func createUser(name: String, email: String) async throws -> User {
        let newUser = CreateUserRequest(name: name, email: email)
        let userData = try JSONEncoder().encode(newUser)
        
        return try await networkManager.request(UserAPI.createUser(userData: userData))
    }
}
```

### 4. Handle Errors

```swift
func loadUser() async {
    do {
        let user = try await userService.fetchUser(id: 123)
        print("User loaded: \(user.name)")
    } catch let error as NetworkError {
        switch error {
        case .invalidURL(let message):
            print("Invalid URL: \(message)")
        case .invalidResponse:
            print("Invalid response from server")
        case .serverError(let statusCode, _):
            print("Server error with status code: \(statusCode)")
        case .decodingError(let error):
            print("Failed to decode response: \(error)")
        }
    } catch {
        print("Unexpected error: \(error)")
    }
}
```

## Advanced Usage

### Custom JSON Decoder

```swift
let customDecoder = JSONDecoder()
customDecoder.dateDecodingStrategy = .iso8601
customDecoder.keyDecodingStrategy = .convertFromSnakeCase

let user: User = try await networkManager.request(
    UserAPI.getUser(id: 123), 
    decoder: customDecoder
)
```

### Authentication Headers

```swift
extension APIEndpoint {
    var headers: [String: String] {
        var headers = ["Content-Type": "application/json"]
        
        if let token = AuthManager.shared.currentToken {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return headers
    }
}
```

### Query Parameters

```swift
case searchUsers(query: String, limit: Int)

// In your endpoint extension:
var queryParameters: [String: String] {
    switch self {
    case .searchUsers(let query, let limit):
        return [
            "q": query,
            "limit": "\(limit)"
        ]
    default:
        return [:]
    }
}
```

### Custom URLSession

```swift
let customSession = URLSession(configuration: .default)
let networkManager = NetworkManager(session: customSession)
```

## Architecture Overview

The NetworkLayer is built with a protocol-oriented architecture consisting of five main components:

### Core Components

1. **`HTTPMethod`**: Enum defining supported HTTP methods (GET, POST, PUT, DELETE)
2. **`NetworkError`**: Comprehensive error handling with detailed error descriptions
3. **`APIEndpoint`**: Protocol defining the structure of API endpoints
4. **`URLRequestBuilder`**: Internal component that builds URLRequest objects from endpoints
5. **`NetworkManager`**: Main interface for making network requests

### Protocol-Oriented Design

```swift
public protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryParameters: [String: String] { get }
    var body: Data? { get }
}
```

This design provides:
- **Flexibility**: Each endpoint can define its specific requirements
- **Type Safety**: Compile-time checking prevents runtime errors
- **Consistency**: All endpoints follow the same contract
- **Testability**: Easy to mock and test individual components

## Error Handling

NetworkLayer provides comprehensive error handling through the `NetworkError` enum:

```swift
public enum NetworkError: Error, LocalizedError {
    case invalidURL(String)
    case invalidResponse
    case serverError(statusCode: Int, response: Data?)
    case decodingError(Error)
}
```

Each error case provides meaningful descriptions that help with debugging and user feedback.

## Testing

NetworkLayer is designed with testing in mind. You can easily mock the `NetworkManager` for unit tests:

```swift
protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint, decoder: JSONDecoder) async throws -> T
}

extension NetworkManager: NetworkManagerProtocol {}

class MockNetworkManager: NetworkManagerProtocol {
    var mockResult: Result<Any, Error>?
    
    func request<T: Decodable>(_ endpoint: APIEndpoint, decoder: JSONDecoder) async throws -> T {
        switch mockResult {
        case .success(let data):
            return data as! T
        case .failure(let error):
            throw error
        case .none:
            throw NetworkError.invalidResponse
        }
    }
}
```

### Development Setup

1. Clone the repository
2. Open `Package.swift` in Xcode
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Author

Created by Mehmet Ali ÇELEBİ

## Changelog

### Version 1.0.0
- Initial release
- Basic networking functionality with async/await support
- Comprehensive error handling
- Protocol-oriented design
- Swift Package Manager support

---

**⭐ If you find this package useful, please consider giving it a star on GitHub!**
