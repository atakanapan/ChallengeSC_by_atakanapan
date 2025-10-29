import Foundation

// MARK: - HTTPClient
protocol HTTPClient {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

// MARK: - URLSessionHTTPClient
final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(configuration: URLSessionConfiguration = .default) {
        configuration.waitsForConnectivity = true
        configuration.allowsConstrainedNetworkAccess = true
        configuration.allowsExpensiveNetworkAccess = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}
