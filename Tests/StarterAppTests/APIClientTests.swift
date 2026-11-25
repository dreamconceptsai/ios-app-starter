import Foundation
import Testing
@testable import StarterApp

/// Intercepts URLSession requests so networking can be tested without a server.
final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// Serialized because the stub's handler is shared state.
@Suite("APIClient", .serialized)
struct APIClientTests {
    private let baseURL = URL(string: "https://api.example.com")!

    private func makeClient() -> APIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return APIClient(baseURL: baseURL, session: URLSession(configuration: configuration))
    }

    private func respond(status: Int, json: String) {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (response, Data(json.utf8))
        }
    }

    @Test("Builds the URL, method and headers")
    func buildsRequest() throws {
        let client = APIClient(baseURL: baseURL)
        let endpoint = Endpoint<[TodoItem]>(
            path: "todos",
            method: .patch,
            queryItems: [URLQueryItem(name: "_limit", value: "20")],
            body: Data("{}".utf8)
        )

        let request = try client.makeRequest(for: endpoint)

        #expect(request.url?.absoluteString == "https://api.example.com/todos?_limit=20")
        #expect(request.httpMethod == "PATCH")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
    }

    @Test("Decodes a successful response")
    func decodesSuccess() async throws {
        respond(status: 200, json: #"[{"id": 7, "title": "Hello", "completed": false, "userId": 1}]"#)

        let items = try await makeClient().send(Endpoint<[TodoItem]>(path: "todos"))

        #expect(items == [TodoItem(id: 7, title: "Hello", completed: false)])
    }

    @Test("Throws on non-2xx status codes")
    func throwsOnHTTPError() async {
        respond(status: 404, json: "{}")

        await #expect(throws: APIError.httpStatus(404)) {
            try await makeClient().send(Endpoint<[TodoItem]>(path: "todos"))
        }
    }

    @Test("Throws a decoding error on bad JSON")
    func throwsOnBadJSON() async {
        respond(status: 200, json: "not json")

        do {
            _ = try await makeClient().send(Endpoint<[TodoItem]>(path: "todos"))
            Issue.record("Expected a decoding error")
        } catch let error as APIError {
            guard case .decoding = error else {
                Issue.record("Expected .decoding, got \(error)")
                return
            }
        } catch {
            Issue.record("Unexpected error \(error)")
        }
    }
}
