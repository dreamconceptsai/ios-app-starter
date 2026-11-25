import Foundation

/// Abstraction over the network so services can be tested with a stub.
protocol HTTPClient: Sendable {
    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response
}

/// Minimal async/await JSON client built on URLSession. No third-party dependencies.
struct APIClient: HTTPClient {
    let baseURL: URL
    let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func send<Response: Decodable & Sendable>(_ endpoint: Endpoint<Response>) async throws -> Response {
        let request = try makeRequest(for: endpoint)

        let result: (Data, URLResponse)
        do {
            result = try await session.data(for: request)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }
        let (data, response) = result

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decoding(String(describing: error))
        }
    }

    func makeRequest<Response: Decodable & Sendable>(for endpoint: Endpoint<Response>) throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appending(path: endpoint.path),
            resolvingAgainstBaseURL: false
        ) else {
            throw APIError.invalidURL
        }
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body = endpoint.body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return request
    }
}
