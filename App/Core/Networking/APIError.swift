import Foundation

enum APIError: Error, LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decoding(String)
    case transport(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "The request URL is invalid."
        case .invalidResponse:
            "The server sent an unexpected response."
        case .httpStatus(let code):
            "The server returned an error (HTTP \(code))."
        case .decoding:
            "The server's data couldn't be read."
        case .transport(let message):
            "Network problem: \(message)"
        }
    }
}
