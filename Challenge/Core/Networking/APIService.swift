import Foundation

// MARK: - APIService
final class APIService {
    // MARK: - Singleton
    static let shared = APIService()
    
    // MARK: - Dependencies
    private let httpClient: HTTPClient
    private let usersCache: UsersCache
    
    // MARK: - Initialization
    init(
        httpClient: HTTPClient = URLSessionHTTPClient(),
        usersCache: UsersCache = DiskUsersCache()
    ) {
        self.httpClient = httpClient
        self.usersCache = usersCache
    }
    
    // MARK: - Public API (Async)
    /// Fetches a page of users using async/await. Supports seed for stable pagination.
    func fetchUsers(
        page: Int,
        results: Int = 25,
        seed: String? = nil
    ) async throws -> RandomUserResponse {
        let endpoint = RandomUserEndpoint(page: page, results: results, seed: seed)
        let url = try endpoint.url()
        
        AppLogger.log("🌐 Fetching users from: \(url.absoluteString)")
        
        do {
            let (data, response) = try await httpClient.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                AppLogger.log("❌ HTTP error: \(httpResponse.statusCode)")
                throw NetworkError.httpError(httpResponse.statusCode)
            }
            
            let decoded = try JSONDecoder().decode(RandomUserResponse.self, from: data)
            AppLogger.log("✅ Successfully fetched \(decoded.results.count) users (page: \(page))")
            
            // Write-through cache (bounded + TTL + LRU).
            await usersCache.write(data, for: endpoint.cacheKey)
            return decoded
        } catch {
            // Offline fallback: try cache if network/decoding fails.
            if let cached = await usersCache.read(for: endpoint.cacheKey),
               let decoded = try? JSONDecoder().decode(RandomUserResponse.self, from: cached) {
                AppLogger.log("📦 Offline cache hit for page \(decoded.info.page)")
                return decoded
            }
            
            AppLogger.log("❌ Network/Decode error: \(error)")
            if let networkError = error as? NetworkError {
                throw networkError
            }
            throw NetworkError.networkError(error)
        }
    }
}

