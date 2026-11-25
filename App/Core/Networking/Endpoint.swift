import Foundation

enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Describes one API call and the type it decodes to.
///
///     let endpoint = Endpoint<[TodoItem]>(path: "todos", queryItems: [URLQueryItem(name: "_limit", value: "20")])
struct Endpoint<Response: Decodable & Sendable>: Sendable {
    var path: String
    var method: HTTPMethod = .get
    var queryItems: [URLQueryItem] = []
    var body: Data? = nil
}
