import Foundation

// MARK: - RandomUserEndpoint
struct RandomUserEndpoint {
    let page: Int
    let results: Int
    let seed: String?
    
    private let baseURL = URL(string: "https://randomuser.me/api/")!
    
    func url() throws -> URL {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        var items = [
            URLQueryItem(name: "results", value: "\(results)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        if let seed = seed {
            items.append(URLQueryItem(name: "seed", value: seed))
        }
        components?.queryItems = items
        guard let url = components?.url else { throw NetworkError.invalidURL }
        return url
    }
    
    /// Cache key (file name stem) for disk cache.
    var cacheKey: String { "\(seed ?? "noseed")_p\(page)_r\(results)" }
}
